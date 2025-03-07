%To add path of the Github repository
addpath(genpath('C:\Users\ksamardzic\Documents\Github\Doktorski-repo'));

load 'C:\Matlab\USE\nowcast_no_safety\nowcast_without_margin.mat';
%load 'D:\Novi kod\data\RDT\Clouddata0109.mat'; 
tic
addpath(genpath(pwd));                  %adds all paths for all subdirs
constants                              %imports constants struct
GlobalParameters
warning('off','MATLAB:polyshape:repairedBySimplify');


%weather data import
Wind=[0,0,0];
%add safety margins
SM = [10, 12.5, 15];

%polygons3d.mat is a product of function nowcast_polygins_final2
%check simulation time is equal to time in nowcast_polygons_final2
load polygons3d.mat;
Clouddata = polygons3d;
NumofNowcastMembers = 15;
NumOfSafetyMargins = 1;
NumOfTOT = 1;

% [Clouddata, NumofNowcastMembers, NumOfSafetyMargins] = nowcast_polygons_final2 (nowcast,SM);
load NeighboorsTable2 NeighboorsTable
load ACsynonyms.mat
load AirportList.mat

AstarGrid.lon1=6;
AstarGrid.lat1=39;
AstarGrid.lon2=23;
AstarGrid.lat2=58;

FlownArea=[39 6 58 23];
raw_so6= 'Traffic0109.so6';
raw_allft = '20210901Initial.ALL_FT+';
desired_time=8*3600;
endtime=desired_time+2*3600;

[allFPL, FPLintent] = allftread2(raw_allft, desired_time, endtime); %this function creates FPLintent that is created by allftread from NEST

%filed flight plan should be copied since waypoints will change to mitigate
%clouds

%data importer (so6reader function) - import ac data from so6 history from NEST 

% [flight_hist,flight_pos,flight] = so6reader_new (raw_so6,desired_time,endtime,FlownArea);
 %load flightdata07072.mat

load ('flight_hist.mat', 'flight_hist');
load ('flight_pos.mat', 'flight_pos');
load ('flight.mat', 'flight');

flight_pos = EOBTinput (FPLintent, flight_pos);
TOT_time_sec = zeros(1, 10);

TrafficArchive(length(flight_pos))=struct();
for a=32%:length(flight_pos)
%% generate each flight
ACarchiveAll = cell(NumofNowcastMembers, NumOfSafetyMargins, NumOfTOT);
ACstateAll = cell (NumofNowcastMembers, NumOfSafetyMargins, NumOfTOT);
ACcontrolAll = cell(NumofNowcastMembers, NumOfSafetyMargins, NumOfTOT);
WPTiAll = cell(NumofNowcastMembers, NumOfSafetyMargins, NumOfTOT);
ACmodeAll = cell(NumofNowcastMembers,NumOfSafetyMargins, NumOfTOT);
TimedifAll = cell(NumofNowcastMembers,NumOfSafetyMargins, NumOfTOT);

TrafficArchive(a).data = cell(NumofNowcastMembers, NumOfSafetyMargins, NumOfTOT);
TrafficArchive(a).tDif = cell(NumofNowcastMembers, NumOfSafetyMargins, NumOfTOT);

%adaptation of spawn time to consider different EOBT
entrytime = flight_pos(a).spawntime;

if entrytime > desired_time
    time_to_EOBT = flight_pos(a).eobt - desired_time; 
    TOT_time_sec = TOT_uncertainty(time_to_EOBT/60, entrytime);
end
if entrytime <= desired_time
    TOT_time_sec = [entrytime, nan(1,9)];
end
    
% Iterate over each nowcast member
    for nowcastMember = 1:NumofNowcastMembers
        
     % Iterate over each safety margin   
    for safetyMarginIndex = 1:NumOfSafetyMargins
 %iterate over each TOT value
    for totIndex = 1:NumOfTOT
   % General simulation parameters:
    SimulationTime=2*3600; %duration of simulation, should be enough for all realistic scenarios.
    ACarchive=zeros(SimulationTime,20);
    
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
    dT=0;

    [AtmHp.T, AtmHp.p, AtmHp.rho, AtmHp.a] = AtmosphereAtHp(ACstate(3), dT, const);
    CL = LiftCoefficient(ACstate(6), AtmHp.rho, opsdata.wingsurf, ACstate(4), ACcontrol(2), const);
    CD = DragCoefficient(CL, opsdata.Cd0.CR,opsdata.Cd2.CR,opsdata.Cd0.geardown);
    
    ACcontrol(4)=CD;   
  

%% simulating traffic

% Get the Clouddata for the current nowcast member
    CurrentCloudData = Clouddata(:, :, nowcastMember, safetyMarginIndex);
       
[ACarchive, ACstate, ACcontrol,WPTi,ACmode] = trajectorygen_Weather_v5_svrljanje (ACstate, ACcontrol, Wind,...
 ACmode, dT, SimulationTime, WPTi, FFP, flight_pos(a).waypoints, opsdata, apfdata,...
 GP, const,ACarchive,AstarGrid,CurrentCloudData,NeighboorsTable, TOT_time_sec(totIndex),endtime,APlist, desired_time);

ACarchive=ACarchive(~(ACarchive(:,1)==0),:);

% figure, hold on, grid on
% for ii = 4:19
%     aux = CurrentCloudData{ii,2};
%     aux = ACarchive(:,21) <= aux;
%     plot(ACarchive(aux,1),ACarchive(aux,2),'bo')
%     for jj = 1:size(CurrentCloudData{ii,3},1)
%         plot(CurrentCloudData{ii,3}{jj,2}(:,2),CurrentCloudData{ii,3}{jj,2}(:,1))
%     end
% end

% axis([15,23,45,47])
% axis equal
% title([num2str(nowcastMember) ' ,' num2str(safetyMarginIndex)])
% keyboard

ACarchiveAll{nowcastMember, safetyMarginIndex,totIndex} = ACarchive;
ACstateAll{nowcastMember,safetyMarginIndex,totIndex} = ACstate;
ACcontrolAll{nowcastMember,safetyMarginIndex,totIndex} = ACcontrol;
WPTiAll{nowcastMember,safetyMarginIndex,totIndex} = WPTi;
ACmodeAll{nowcastMember,safetyMarginIndex,totIndex} = ACmode;

ACsimtime=size(ACarchiveAll{nowcastMember}, safetyMarginIndex,totIndex);
ACso6time=strcmp({flight.name},flight_pos(a).name);
 toc          
    end
    end
end
save ('TrafficArchive.mat', 'TrafficArchive');
%save ('leadTimeInSeconds', 'leadTimeInSeconds');
 %% Visualisation

 %figure;
% 
% % 
%  for i =  2% 1:NumofNowcastMembers
%      for j = 1:NumOfSafetyMargins
%      data = TrafficArchive(89).data{i,j};
%      plot(data(:, 1), data(:, 2));
%     hold on
%      end
%  end



%complexity assessment

%visualization and analysis
%[f]=makemapbaseEur([40 50], [0 30]); %test - creates map base
%marks = addflightstomap(f, flight_pos); %test - adds markers at A/C pos
%delete(marks) %test - deletes markers (for animation purposes)
end