function [TrafficArchive] = TPfunction (flight_pos,dT,const,ACsynonyms,Wind,GP,AstarGrid,...
    endtime,APlist,Clouddata,NeighboorsTable,flight)
%this function will trigger TP for AC
TrafficArchive(length(flight_pos))=struct();
for a=1:length(flight_pos)
    %%set variable filed flight plan
    
    FFP=flight_pos(a).waypoints;
    
    %all initial variables of aircraft modes must be defined on first
    %iteration and are set in ACmode struct.
   
    ACmode.ACC='C'; % Acceleration mode: (A)cceleration, (C)onstant, (D)ecceleration.
    
    if flight_pos(a).mode==0
        ACmode.CL='C'; % Climb mode: (C)limb, (L)evel, (D)escent
    elseif flight_pos(a).mode==1
        ACmode.CL='D'; % Climb mode: (C)limb, (L)evel, (D)escent
    elseif flight_pos(a).mode==2
        ACmode.CL='L'; % Climb mode: (C)limb, (L)evel, (D)escent
    end
    
    ACmode.ConfigMode='CL'; % Aircraft configuration mode: (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
    ACmode.SpeedMode='C'; % Speed hold mode: (C)AS or (M)ach
    ACmode.tropo=false; %Is aircraft above tropopause?
    ACmode.incloud=0; %It can be 0 (out) or 1 (in) 
    
    
    %initial AC movement variables:
    WPTi=2; %/Waypoint index. It marks the next waypoint in the waypoint list.
    ACmode.StillFlying=true;
    
    % General simulation parameters:
    SimulationTime=7200; %duration of simulation, should be enough for all realistic scenarios.
    
    %reading BADA data

    AC=char(ACsynonyms(strcmp(ACsynonyms(:,1),char(flight_pos(a).type)),2));

        
    opsdata = readOPFfile([AC,'.OPF']);
    apfdata = readAPFfile([AC,'.APF']);
    
    %creating start ACstate data
    ACstate=[flight_pos(a).xpos, flight_pos(a).ypos, flight_pos(a).zpos,...
        flight_pos(a).GS, flight_pos(a).track, opsdata.mref*1000];
    
    if ACstate(3) < 150
        ACmode.ACC='A';
        ACmode.CL='C';
        ACmode.ConfigMode='T';
        ACstate(4)=70;
        ACstate(3)=1;
    end
    
    if ACstate(4) < 100
        ACstate(4)=100;
    end
    
    %This statement will reduce mass of AC which are flyining within 6% of
    %their ceiling
    if ACstate(3)>opsdata.maxalt*0.3048*0.94
        ACstate(6)=ACstate(6)*0.8; %ovo bi trebalo malo provjeriti;
    end
    
   FlightPath=flight_pos(a).waypoints;
   MaxAlt=max([FFP(:).z]);
   if MaxAlt>opsdata.Hmax*0.3048
       ACstate(6)=1000*(opsdata.mref+opsdata.mmin)/2;
   elseif deg2nm(distance(FlightPath(1).y,FlightPath(1).x,FlightPath(end).y,FlightPath(end).x))<250
       ACstate(6)=1000*((opsdata.mref-opsdata.mmin)*0.2+opsdata.mmin);
   end
   
   
    ACcontrol=[300,0,0,0];
   % dT=5;

    [AtmHp.T, AtmHp.p, AtmHp.rho, AtmHp.a] = AtmosphereAtHp(ACstate(3), dT, const);
    CL = LiftCoefficient(ACstate(6), AtmHp.rho, opsdata.wingsurf, ACstate(4), ACcontrol(2), const);
    CD = DragCoefficient(CL, opsdata.Cd0.CR,opsdata.Cd2.CR,opsdata.Cd0.geardown);
    
    ACcontrol(4)=CD;
    ACarchive=zeros(SimulationTime,20);
  

%% simulating traffic


[ACarchive, ~, ~,~,ACmode] = trajectorygen_Weather_v5 (ACstate, ACcontrol, Wind,...
 ACmode, dT, SimulationTime, WPTi, FFP, flight_pos(a).waypoints, opsdata, apfdata,...
 GP, const,ACarchive,AstarGrid,Clouddata,NeighboorsTable, flight_pos(a).spawntime,endtime,APlist);


    ACarchive=ACarchive(~(ACarchive(:,1)==0),:);
    
    TrafficArchive(a).name=flight_pos(a).name;
    TrafficArchive(a).data=ACarchive;
    ACsimtime=size(ACarchive,1);
    ACso6time=strcmp({flight.name},flight_pos(a).name);
    if flight(ACso6time).time(end,2)>endtime
        et=endtime;
    else
        et=flight(ACso6time).time(end,2);
    end
    ACso6time=et-flight_pos(a).spawntime;
    TrafficArchive(a).tDif=[ACsimtime ACso6time ACsimtime/ACso6time ACsimtime-ACso6time ACsimtime/ACso6time-1];
    
  
    [a, size(flight_pos,2), a/size(flight_pos,2)]
end


end