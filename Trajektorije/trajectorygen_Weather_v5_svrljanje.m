function [ACarchive, ACstate, ACcontrol,WPTi,ACmode] = trajectorygen_Weather_v5_svrljanje (ACstate,...
    ACcontrol, Wind, ACmode, dT, SimulationTime, WPTi,FFP, ...
    waypoints, opsdata, apfdata, GP, const, ACarchive,...
    AstarGrid,Clouddata, NeighboorsTable,Loctime,endtime,APlist, desired_time)
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

%----------------
% V4 version - CloudMaps in 3D!
%-----------------

%if ac is right before landing function will be killed        
if max([waypoints.z])<160
    ACarchive=zeros(1,21);
    return
end
    
WPtime=1:60:SimulationTime+1;
WPn=1;
timestep=1;
wp=2;
Altlist=1:60;
ACalt=ACstate(3);
Altp=abs(ACalt*3.28084/1000-Altlist);
[~,altFL]=min(Altp);

 %Ova petlja stavlja NaN ako je Loctime NaN, tj. ako je zrakoplov u zraku u
 %na poèetku simulacije 
if isnan(Loctime)
    ACarchive(timestep,1)=NaN; 
    ACarchive(timestep,2)=NaN;
    ACarchive(timestep,3)=NaN;
    ACarchive(timestep,4)=NaN;
    ACarchive(timestep,5)=NaN;
    ACarchive(timestep,6)=NaN;
    ACarchive(timestep,7)=NaN;
    ACarchive(timestep,8)=NaN;
    ACarchive(timestep,9)=NaN;
    ACarchive(timestep,10)=NaN;
    ACarchive(timestep,11)=NaN; 
    ACarchive(timestep,12)=NaN;
    ACarchive(timestep,13)=NaN;
    ACarchive(timestep,14)=NaN;    
    ACarchive(timestep,15)=NaN;
    ACarchive(timestep,16)=NaN;
    ACarchive(timestep,17)=NaN;
    ACarchive(timestep,18)=NaN;
    ACarchive(timestep,19)=NaN;
    ACarchive(timestep,20)=NaN;
    ACarchive(timestep,21)=NaN; 
else  

%check if AC is landing for CDA
wpts=size(waypoints,2);
ldg=0;
cda=0;
if max(strcmp(FFP(end).name,APlist))==1
    [waypoints] = CDA (waypoints, ACstate,WPTi,dT,const,ACmode,GP,apfdata,opsdata,ACcontrol,Wind);
    ldg=1;
    %FFP=waypoints;
end


%creating cloud maps for astar routes (this should be in trajectory gen
%maybe)
cloudtime=[Clouddata{:,2}]';
[~,cpos]=min(abs(Loctime-cloudtime));

if Loctime<cloudtime(cpos)
    cpos=cpos-1;
end

if cpos==0
    cpos=1;
end 

[~, ~, CloudAlt,cloudMap3D] = cloudMerge_svrljanje (Clouddata{cpos,3},AstarGrid);
    
while ACmode.StillFlying
    
    currenttime=Loctime+timestep-1;
    
    
    % 0. Evaluate trajectory and update of trajectory based on clouds;
    %load cloud data
    if max(currenttime==cloudtime)==1
        [~, ~, CloudAlt,cloudMap3D] = cloudMerge_svrljanje (Clouddata{currenttime==cloudtime,3},AstarGrid);
    end
    
    
    %selecting cloud altitude layer
    ACalt=ACstate(3);
    Altp=abs(ACalt*3.28084/1000-Altlist);
    oldFL=altFL;
    [~,altFL]=min(Altp);
    %this part of code will look vertically if ac is in climb or descent to check for
    %cloud crossing and will use first upper level wehere ac cross cloud
    %for astar pathfinding
    %wp is switch to no repeat loop every second, rather on every WPTi
    %change
    if ACmode.CL=='C' && oldFL~=altFL
        [~,wpFL]=min(abs(waypoints(WPTi).z*3.28084/1000-Altlist));
        altdif=wpFL-altFL;
        CLtest=zeros(altFL+altdif,1);
        for a=altFL:altFL+altdif
            if~isempty(CloudAlt{a})
                CLtest(a)=CloudTest (ACstate,CloudAlt{a});
            end
        end
        if max(CLtest)==1
        [~,altFL]=max(CLtest);
        else
            [~,altFL]=min(Altp);
        end
        
    elseif ACmode.CL=='D' && oldFL~=altFL
        [~,wpFL]=min(abs(waypoints(WPTi).z*3.28084/1000-Altlist));
        altdif=altFL-wpFL;
        CLtest=zeros(altFL+altdif,1);
        for a=altFL-altdif:altFL
            if~isempty(CloudAlt{a})
                CLtest(a)=CloudTest (ACstate,CloudAlt{a});
            end
        end
        if max(CLtest)==1
        [~,altFL]=max(flip(CLtest)); 
        else
            [~,altFL]=min(Altp);
        end
    end
    
    CloudsAll=CloudAlt{altFL};
    cloudMap=cloudMap3D(:,:,altFL);
    
    
        %this part of code will add waypoint for vectoring out of cloud if ac is
        if ~isempty(CloudsAll)
            if inpolygon(ACstate(2),ACstate(1),CloudsAll(:,1),CloudsAll(:,2)) == 1
                if ACmode.incloud==0

                   ACmode.incloud=1;
                   t=1;
                elseif ACmode.incloud==1
                    % t=5 to wait for 5 seconds before calculating new
                    % trajectory due to errors from borders

                        %selecting initial FFP wpt
                        ch=extractfield(waypoints,'hist');
                        if ch(WPTi)==0
                            WPTffp=sum(ch(1:WPTi))+1; %all previous next wpt;
                        else
                            WPTffp=sum(ch(1:WPTi));
                        end

                    if t==5
                        [WPT] = CloudOutVector (ACstate,CloudsAll);
                       if ~isempty(WPT)
                           [waypointsnew,FFP]= WPTupdateCloud (WPT,waypoints,WPTi,FFP,WPTffp);
                           waypoints=waypointsnew;
                           t=t+1;
                       end
                    else
                        t=t+1;
                    end

                end


            else
                if ACmode.incloud==1
                    ACmode.incloud=0;

                end
            end
        end
    % this will triger every minute
    if timestep==WPtime(WPn)
        %this part will triger astar if look-ahead 80NM crosses any clouds
         if ~isempty(CloudsAll)
            if CloudTest (ACstate,CloudsAll)==1
                %this part will check if distance to next WPT is less than
                %10 NM, if it is and AC is in front of cloud it will change
                %to next WPT
                if deg2nm(distance(ACstate(2),ACstate(1),waypoints(WPTi).y,waypoints(WPTi).x))<40 ...
                        && WPTi<size(waypoints,2)-1
                    WPTi=WPTi+1;
                end
                if sqrt((ACstate(1)-waypoints(WPTi).x)^2+(ACstate(2)-waypoints(WPTi).y)^2)/4*60>3
                    if ACmode.incloud==0
                        %this function start astar algorithm to find best path to initial
                        %Filed Flight Plan waypoint

                        %selecting initial FFP wpt
                        ch=extractfield(waypoints,'hist');
                        if ch(WPTi)==0
                            WPTffp=sum(ch(1:WPTi))+1; %all previous next wpt;
                        else
                            WPTffp=sum(ch(1:WPTi));
                        end

                        %adding exception when WPTffp change due to fp change
                        if exist('WPTffpn','var')
                            if WPTffpn>WPTffp
                                WPTffp=WPTffpn;
                            end
                        end
                        %Modified Astar
                        [NewFP,NewWPT,WPTffpn] = AstarRoute_v4 (AstarGrid.lon1, AstarGrid.lon2, AstarGrid.lat1,...
                            AstarGrid.lat2, CloudsAll, [ACstate(2),ACstate(1)],NeighboorsTable,...
                            cloudMap,ACstate(5),FFP,WPTffp);
                        
                        %this part is to skip all successive WPTs that are
                        %in colouds
                        d=WPTffpn-WPTffp;
                        WPTi=WPTi+d;

                        if ~isempty(NewWPT)
                            %changing waypoints if current one is within polygon
                            ch2=ch(WPTi:end);
                            WPTffp2=find(ch2,1,'first');
                            WPTffp2=WPTi+WPTffp2-1; %-1 is because in finding proccess 1 was added


                            waypoints(WPTffp2).y=NewWPT(1);
                            waypoints(WPTffp2).x=NewWPT(2);
                        end

                        if size(NewFP,1)>2

                            waypoints= wptcut (waypoints,NewFP,WPTi);
                            %skip first WPT if it is too close to AC
                            %position
                            TurnRadius = ACstate(4)*ACstate(4)/(const.g0*tand(GP.phi_nom_oth));
                            while deg2nm(distance(ACstate(2),ACstate(1),waypoints(WPTi).y,waypoints(WPTi).x))<TurnRadius*1.2/1852
                                WPTi=WPTi+1;
                            end
                        end
                    end
                end
            end
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
    
    if ACstate(3)>=TransAlt  %switch for constant CAS or Mach in respect to Transition (crossover) altitude
        ACmode.SpeedMode='M';
    else
        ACmode.SpeedMode='C';
    end
    
    % 4. Determine phase of flight: (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
    ACmode.CL=CLModeSet(ACstate(3),waypoints(WPTi).z,ACmode.CL,GP.Htol); %setting AC regime
    ACmode.ConfigMode=ConfigModeSet(GP,opsdata,ACstate(3),CAScurrent,ACmode.CL); %Setting config mode
    
    % 5. Determine acceleration mode: (A)ccelerating, (C)onstant, (D)ecelerating, and desired TAS
    desiredTAS = DesiredTASf (GP,apfdata,opsdata,ACmode.CL,ACstate(6),AtmHp,ACmode.ConfigMode,ACstate(3),TransAlt,const);
    if timestep==1 && ACstate(4)>desiredTAS %since initial speed is based on GS if speed is too high due to wind it is corrected
        ACstate(4)=desiredTAS;
    end
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
   
    if (currenttime >= desired_time) && (currenttime <= endtime)
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
    ACarchive(timestep,21)=currenttime; 
    % ACarchive(21)=waypoints(WPTi).t;
    end
    
    % if Loctime is smaller than desired_time, lines won't be written
    if (currenttime < desired_time) && (currenttime > endtime)
    ACarchive(timestep,1)=NaN; 
    ACarchive(timestep,2)=NaN;
    ACarchive(timestep,3)=NaN;
    ACarchive(timestep,4)=NaN;
    ACarchive(timestep,5)=NaN;
    ACarchive(timestep,6)=NaN;
    ACarchive(timestep,7)=NaN;
    ACarchive(timestep,8)=NaN;
    ACarchive(timestep,9)=NaN;
    ACarchive(timestep,10)=NaN;
    ACarchive(timestep,11)=NaN; 
    ACarchive(timestep,12)=NaN;
    ACarchive(timestep,13)=NaN;
    ACarchive(timestep,14)=NaN;    
    ACarchive(timestep,15)=NaN;
    ACarchive(timestep,16)=NaN;
    ACarchive(timestep,17)=NaN;
    ACarchive(timestep,18)=NaN;
    ACarchive(timestep,19)=NaN;
    ACarchive(timestep,20)=NaN;
    ACarchive(timestep,21)=NaN; 
    end
    
    % calculate next ACstate
    ACstate = ACStateUpdate(ACstate, ACcontrol, Wind,  opsdata.wingsurf,  AtmHp.rho,  FF, CL, const);
    
    % 10. Reached next waypoint?
    DistToNext = distance(ACstate(2),ACstate(1),waypoints(WPTi).y,waypoints(WPTi).x);
    DistToNext = deg2km(DistToNext)*1000;
    TurnRadius = ACstate(4)*ACstate(4)/(const.g0*tand(GP.phi_nom_oth));
  
    
    if strcmp(waypoints(WPTi).name,'END') 
        if distance(ACstate(2),ACstate(1),waypoints(WPTi).y,waypoints(WPTi).x )<10
            ACmode.StillFlying = false;
        end
    end
    
    if (waypoints(WPTi).flyover == 1 && DistToNext < TurnRadius * 0.1)
        WPTi = WPTi + 1;
 
    elseif (waypoints(WPTi).flyover == 0 && DistToNext < TurnRadius)
        WPTi = WPTi + 1;
  
    elseif strcmp(waypoints(WPTi).name,'addedWPT') && DistToNext < TurnRadius*0.6
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
    
    if currenttime>=endtime-1
        ACmode.StillFlying = false; 
    end
   
    if ACstate(3)<-100
        ACmode.StillFlying = false; 
    end
    
    %this code will cut steep turns caused by astar by skipping FFP WPTi
    %which requires significant heading changes
    
    if wp~=WPTi && WPTi<size(waypoints,2)-1 && ~(strcmp(waypoints(WPTi).name,'addedWPT')) && strcmp(waypoints(WPTi-1).name,'addedWPT')...
            && strcmp(waypoints(WPTi-2).name,'addedWPT')
        hdg1=atan2(waypoints(WPTi-1).x-waypoints(WPTi).x,waypoints(WPTi-1).y-waypoints(WPTi).y);
        hdg2=atan2(waypoints(WPTi).x-waypoints(WPTi+1).x,waypoints(WPTi).y-waypoints(WPTi+1).y);
        hdg3=atan2(waypoints(WPTi+1).x-waypoints(WPTi+2).x,waypoints(WPTi+1).y-waypoints(WPTi+2).y);
        
        if abs(hdg1-hdg2)>1.0472 % if change in hdg is more than 60 degrees
           WPTi=WPTi+1;  %switch to next waypoint 
        elseif abs(hdg2-hdg3)>1.0472
           WPTi=WPTi+1;
        end
        
    end
    
%     %recheck for CDA due to additional WPTs
if ~strcmp(waypoints(1).name,'CDA')
    if ldg==1
        if timestep==WPtime(WPn)
            dtoAP=distance(ACstate(2),ACstate(1),waypoints(end).y,waypoints(end).x);
            %check if there way any rerotes after 120 mark, if it has
            %recalculate CDA point
            if size(waypoints,2)>wpts
                cda=0;
            end

            if deg2nm(dtoAP)<120 && cda==0 && ACstate(3)>900
                cda=1;
               [waypoints] = CDA2 (waypoints, ACstate,WPTi,dT,const,ACmode,GP,apfdata,opsdata,ACcontrol,Wind);
                wpts=size(waypoints,2);
            end
        end
    end
end

%     if wp~=WPTi && WPTi==size(waypoints,2) && inpolygon(waypoints(WPTi).y,waypoints(WPTi).x,CloudsAll(:,1),CloudsAll(:,2)) == 1
%         
%     end
    
    %check for descent to add tod
    if wp~=WPTi && WPTi<=size(waypoints,2)
        if waypoints(WPTi).z<waypoints(WPTi-1).z && ~(strcmp(waypoints(WPTi-1).name,'TOD'))
            CDAt=[waypoints.name]';
            n=1:size(CDAt);
            n=n(strcmp(CDAt,'CDA'));
            if WPTi<=n
               waypoints= TOD2 (waypoints, ACstate,WPTi,dT,const,ACmode,GP,apfdata,opsdata,ACcontrol,Wind);
               [FFP] = FFPtodf (waypoints);
            elseif isempty(n)
               waypoints= TOD2 (waypoints, ACstate,WPTi,dT,const,ACmode,GP,apfdata,opsdata,ACcontrol,Wind);
               [FFP] = FFPtodf (waypoints); 
            end
        end
        wp=WPTi;
    end
       
end

end
end

