function [wptlist] = TOD2 (waypoints, ACstate,WPTi,dT,const,ACmode,GP,apfdata,opsdata,ACcontrol,Wind)
%this function will check if AC is landing at next WPT and calculate TOD
%for descent
t=1;
    if strcmp(ACmode.ConfigMode,'CL')==1
       ACstate(3)=waypoints(WPTi-1).z;
    end
ACstart=[ACstate(1) ACstate(2)];
while ACstate(3)>waypoints(WPTi).z+150
    
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

    % calculate next ACstate
    ACstate = ACStateUpdate(ACstate, ACcontrol, Wind,  opsdata.wingsurf,  AtmHp.rho,  FF, CL, const);
t=t+1;
end

az=azimuth(ACstart(2),ACstart(1),waypoints(WPTi).y,waypoints(WPTi).x);
distAC=distance(ACstart(2),ACstart(1),ACstate(2),ACstate(1));
dist=distance(waypoints(WPTi).y,waypoints(WPTi).x,ACstart(2),ACstart(1));

     if dist>distAC

     az=az-180;
     if az<0
         az=az+360;
     end

    [latout,lonout]=reckon(waypoints(WPTi).y,waypoints(WPTi).x,distAC+5/60,az);

    A=waypoints(1:WPTi-1);
    B.y=latout;
    B.x=lonout;
    B.z=waypoints(WPTi-1).z;
    B.flyover=0;
    B.hist=1;
    B.name={'TOD'};
    C=waypoints(WPTi:end);

    wptlist=[A,B,C];

     else
         waypoints(WPTi).name={'TOD'};
         wptlist=waypoints;
     end

end