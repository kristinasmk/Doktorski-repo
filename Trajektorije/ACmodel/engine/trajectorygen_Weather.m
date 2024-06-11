function [ACarchive, ACstate, ACcontrol,WPTi,ACmode] = trajectorygen_Weather (ACstate,...
    ACcontrol, Wind, ACmode, dT, SimulationTime, WPTi,FFP, ...
    waypoints, opsdata, apfdata, GP, const, timestep, ACarchive,AstarGrid,Clouds,NeighboorsTable)
%function that generates aircraft trajectory
%input parameters for simulations should be:
%---- Aircraft states ----                  ACstate
% x - AC position longitude  [DDD.dddd]
% y - AC position latitude   [DD.dddd]
% h - AC altitude            [m]
% TAS - AC true airspeed     [m/s]
% hdg - AC heading           [rad]
% mass - mass of aircraft    [kg]
%
%---- Wind components -------               Wind
% wx - wind speed in x axis  [m/s]
% wy - wind speed in y axis  [m/s]
% wh - wind speed in h axis  [m/s] 
%
%initial ACstate parameters are obtained from so6reader
%
%---- Aircraft control paramethers -----    ACcontrol
% thrust                     [N]
% bank                       [rad]
% pitch                      [rad]
% drag                       [dimensionless]
%
%control parameters are initially defult but they are set on first cycle
%
%
%
%other input variables:
% dT - Temperature difference from ISA standard temperature at MSL, 
%               which is 288.15K. (Kelvins)
% const - constants struct, must contain BetaT, Hp_trop, R, g
% waypoints - obtained from allft read 
% SimulationTime - duration of simulation
% WPTi - index of current waypoint
% opsdata - OPF data from BADA
% apfdata - APF data from BADA
% GP - Global Paramethers from BADA
% const - constants

WPtime=1:60:SimulationTime;
WPn=1;

while ACmode.StillFlying
    % 0. Evaluate trajectory and update of trajectory based on clouds;
    
    if timestep==WPtime(WPn)
        %this function start astar algorithm to find best path to initial
        %Filed Flight Plan waypoint
        
        %selecting initial FFP wpt
        ch=extractfield(waypoints,'hist');
        if ch(WPTi)==0
            WPTffp=sum(ch(1:WPTi))+1; %all previous next wpt;
        else
            WPTffp=sum(ch(1:WPTi));
        end
        
        %Modified Astar
        [NewFP,NewWPT] = AstarRoute (AstarGrid.lon1, AstarGrid.lon2, AstarGrid.lat1,...
            AstarGrid.lat2, Clouds, [ACstate(2),ACstate(1)],...
            [FFP(WPTffp).y,FFP(WPTffp).x],NeighboorsTable);
        
        if ~isempty(NewWPT)
            
            ch2=ch(WPTi:end);
            WPTffp2=find(ch2,1,'first');
            WPTffp2=WPTi+WPTffp2-1; %-1 is because in finding proccess 1 was added
            waypoints(WPTffp2).y=NewWPT(1);
            waypoints(WPTffp2).x=NewWPT(2);
        end
        
        if size(NewFP,1)>2
            
            waypoints= wptcut (waypoints,NewFP,WPTi);
        end
        WPn=WPn+1;
    end
    % 1. Determine conditions at current alt for current meteo
    [AtmHp.T, AtmHp.p, AtmHp.rho, AtmHp.a] = AtmosphereAtHp(ACstate(3), dT, const);
    
    % 2. Determine altitude
    % [geopotential_alt]=GeodeticToGeopotential(const, geodetic_alt); 
    if ACstate(3)>11000 
        ACmode.tropo=true;
    else
        ACmode.tropo=false;
    end
    % 3. Determine all speeds (TAS to CAS to Mach)
    CAScurrent=TAStoCAS(AtmHp.p, AtmHp.rho, ACstate(4)); %ACstate(4) - TAS
    MACHcurrent=TAStoMach(AtmHp.T, ACstate(4));
    TransAlt=CrossAlt(CAScurrent, MACHcurrent, dT, const);
    
    if ACstate(3)>TransAlt  %switch for constant CAS or Mach in respect to Transition (crossover) altitude
        ACmode.SpeedMode='M';
    else
        ACmode.SpeedMode='C';
    end
    
    % 4. Determine phase of flight: (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
    ACmode.CL=CLModeSet(ACstate(3),waypoints(WPTi).z,ACmode.CL,GP.Htol); %setting AC regime
    ACmode.ConfigMode=ConfigModeSet(GP,opsdata,ACstate(3),CAScurrent,ACmode.CL); %Setting config mode
    
    % 5. Determine acceleration mode: (A)ccelerating, (C)onstant, (D)ecelerating, and desired TAS
    desiredTAS = DesiredTASf (GP,apfdata,opsdata,ACmode.CL,ACstate(6),AtmHp,ACmode.ConfigMode,ACstate(3),TransAlt,const);
    ACmode.ACC = ACCModeSet (ACstate(4),desiredTAS,ACmode.ACC,GP.Vtol);
    
    % 6. Determine energy share factor
    esf=energysf(MACHcurrent, AtmHp.T, dT, ACmode.ACC, ACmode.CL, ACmode.SpeedMode, ACmode.tropo, const);
    
    % 7. Determine ACcontrol inputs
    %   7.a. Lift and Drag
        CL = LiftCoefficient(ACstate(6), AtmHp.rho, opsdata.wingsurf, ACstate(4), ACcontrol(2),const);
        ACcontrol(4)= ACDragCoef (opsdata, ACmode.ConfigMode, CL);
    %   7.b. Thrust
        ACcontrol(1)= ThrustSet (GP, opsdata, ACstate, ACcontrol, AtmHp, ACmode, desiredTAS, const);
    %   7.c. Pitch
        ACcontrol(3)=PitchSet (opsdata, GP, ACstate, ACcontrol, waypoints(WPTi).z, esf, AtmHp, const);
    %   7.d. Bank
        ACcontrol(2)=BankSet (GP, ACstate, ACcontrol, waypoints, WPTi,ACmode.ConfigMode, Wind, const);
    
    % 8. Fuel consumption
    FF = FuelConsumption(ACstate(4), ACcontrol(1),  ACstate(3), ...
        opsdata.Cf1,  opsdata.Cf2,  opsdata.Cf3,  opsdata.Cf4, ...
        opsdata.Cfcr, opsdata.engtype, ACmode.CL);
    
    % 9. Update ACstate
    % Archive current state
    ACarchive(timestep,1)=ACstate(1);  % za ACstate_archive bi trebalo unaprijed odrediti zeros matricu
    ACarchive(timestep,2)=ACstate(2);
    ACarchive(timestep,3)=ACstate(3);
    ACarchive(timestep,4)=ACstate(4);
    ACarchive(timestep,5)=ACstate(5);
    ACarchive(timestep,6)=ACstate(6);
    ACarchive(timestep,7)=ACcontrol(1);
    ACarchive(timestep,8)=ACcontrol(2);
    ACarchive(timestep,9)=ACcontrol(3);
    ACarchive(timestep,10)=ACcontrol(4);
    ACarchive(timestep,11)=desiredTAS; 
    ACarchive(timestep,12)=esf;
    ACarchive(timestep,13)=CAScurrent;
    ACarchive(timestep,14)=MACHcurrent;    
    [WindDir,WindSpd] = cart2compass(-Wind(1),-Wind(2));
    [track,GS] = ACdrift(ACstate(5),ACstate(4),WindDir,WindSpd);
    ACarchive(timestep,15)=track;
    ACarchive(timestep,16)=GS;
    ACarchive(timestep,17)=WPTi;
    ACarchive(timestep,18)=waypoints(WPTi).x;
    ACarchive(timestep,19)=waypoints(WPTi).y;
    ACarchive(timestep,20)=waypoints(WPTi).z;
    % ACarchive(21)=waypoints(WPTi).t;
    % calculate next ACstate
    ACstate = ACStateUpdate(ACstate, ACcontrol, Wind,  opsdata.wingsurf,  AtmHp.rho,  FF, CL, const);
    
    % 10. Reached next waypoint?
    DistToNext = distance(ACstate(2),ACstate(1),waypoints(WPTi).y,waypoints(WPTi).x);
    DistToNext = deg2km(DistToNext)*1000;
    TurnRadius = ACstate(4)*ACstate(4)/(const.g0*tand(GP.phi_nom_oth));
    
    if (waypoints(WPTi).flyover == 1 && DistToNext < TurnRadius * 0.1)
        WPTi = WPTi + 1;
    elseif (waypoints(WPTi).flyover == 0 && DistToNext < TurnRadius)
        WPTi = WPTi + 1;
    end
    
    % 11. Reached last waypoint?
    if (WPTi > numel(waypoints)) 
        ACmode.StillFlying = false; 
    end
    timestep = timestep + 1;
    
    if (timestep >= SimulationTime -1)
        ACmode.StillFlying = false; 
    end
    
    
end

end
