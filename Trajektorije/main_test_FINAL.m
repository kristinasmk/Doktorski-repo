traffic_batch = 40;
addpath(genpath('C:\Users\ksamardzic\Documents\GitHub\Doktorski-repo'));
load ('flight_pos.mat', 'flight_pos');
for batch = 401:traffic_batch:length(flight_pos)
    batch_end = min(batch + traffic_batch - 1, length(flight_pos));
    TrafficArchive(batch:batch_end) = struct();
%To add path of the Github repository
addpath(genpath('C:\Users\ksamardzic\Documents\Github\Doktorski-repo'));
addpath(genpath(pwd));                  %adds all paths for all subdirs

%Load required data
load 'C:\Users\ksamardzic\Documents\GitHub\Doktorski-repo\nowcast_no_safety\nowcast_without_margin.mat'; %loads weather product
%load 'D:\Novi kod\data\RDT\Clouddata0109.mat'; 
load polygons3d.mat; %polygons3d.mat is a product of function nowcast_polygins_final2
load NeighboorsTable2 NeighboorsTable;
load ACsynonyms.mat;
load AirportList.mat;
load ('allFPL.mat', 'allFPL');
load ( 'FPLintent.mat', 'FPLintent');
load ('flight_hist.mat', 'flight_hist');

load ('flight.mat', 'flight');

%Define constants
constants                              %imports constants struct
GlobalParameters
warning('off','MATLAB:polyshape:repairedBySimplify');
 
%Simulation parameters
Wind=[0,0,0];
SM = [10, 12.5, 15]; %add safety margins
Clouddata = polygons3d;
NumofNowcastMembers = 15;
NumOfSafetyMargins = 3;
NumOfTOT = 10;
SimulationTime = 1.5 * 3600; 
desired_time=7.75*3600; %start of simulation 7:45
endtime=desired_time+ SimulationTime; %end of simulation 9:15

% [Clouddata, NumofNowcastMembers, NumOfSafetyMargins] = nowcast_polygons_final2 (nowcast,SM);

%dimensions of a FlownArea should match AstarGrid
AstarGrid = struct('lon1', 5, 'lat1', 38, 'lon2', 24, 'lat2', 59);
FlownArea=[39 6 58 23];

%Raw traffic Data files
raw_so6= 'Traffic0109.so6'; %Traffic from Nest
raw_allft = '20210901Initial.ALL_FT+'; %FFP

% [allFPL, FPLintent] = allftread2(raw_allft, desired_time, endtime); %this function creates FPLintent that is created by allftread from NEST

% load ('allFPL.mat', 'allFPL');
% load ( 'FPLintent.mat', 'FPLintent');
%function to extract flights within desired time and area
% [flight_hist,flight_pos,flight] = so6reader_new (raw_so6,desired_time,endtime,FlownArea);

%function to add EOBT time to flight_pos
flight_pos = EOBTinput (FPLintent, flight_pos);
TOT_time_sec = zeros(1, 10);
    
for a= batch:batch_end
disp(['Processing flight: ', num2str(a)]);

%% generate each flight
ACarchiveAll = cell(NumOfSafetyMargins, NumOfTOT);
ACstateAll = cell (NumOfSafetyMargins, NumOfTOT);
ACcontrolAll = cell(NumOfSafetyMargins, NumOfTOT);
WPTiAll = cell(NumOfSafetyMargins, NumOfTOT);
ACmodeAll = cell(NumOfSafetyMargins, NumOfTOT);
TimedifAll = cell(NumOfSafetyMargins, NumOfTOT);

TrafficArchive(a).data = cell(NumOfSafetyMargins, NumOfTOT);
TrafficArchive(a).tDif = cell(NumOfSafetyMargins, NumOfTOT);

%adaptation of spawn time to consider different EOBT
entrytime = flight_pos(a).spawntime;

if entrytime > desired_time
    time_to_EOBT = flight_pos(a).eobt - desired_time; 
    if time_to_EOBT < 0 %if aircraft enters FlownArea after the simulatio start but was airborne before simulation, TOT uncertainty is not applicable
        TOT_time_sec = [entrytime, nan(1,9)];
    else
    %this function provides all possible TOT based on TOT uncertainty distribution
    %applicable only on those aircraft who are not airborne at the beginning of simulation
    [TOT_time_sec, selected_dep_times] = TOT_uncertainty(time_to_EOBT/60, entrytime); 
    end
end

if entrytime <= desired_time
    time_to_EOBT = flight_pos(a).eobt - desired_time; 
    TOT_time_sec = [entrytime, nan(1,9)];
end
    
% Iterate over each nowcast member
    for nowcastMember = 2%:NumofNowcastMembers
        tic
        disp(['Nowcasting member: ', num2str(nowcastMember)]);
        
        %provjera presijeca li planirana ruta bilo koji oblak
        [~, intersected, intersected_points] = crossing_check(Clouddata, AstarGrid, flight_pos(a).waypoints, nowcastMember);  
        if intersected ==1
            safetyMarginRange = 1:NumOfSafetyMargins;
            TOTRange = 1: NumOfTOT;
        else
            safetyMarginRange = 1;
            TOTRange = 1;
        end
        
     % Iterate over each safety margin   
    for safetyMarginIndex = safetyMarginRange
        disp(['Safety margin: ', num2str(safetyMarginIndex)]);
        
   CurrentCloudData = Clouddata(:, :, nowcastMember, safetyMarginIndex);
 %iterate over each TOT value
    for totIndex = TOTRange
        disp(['TOT index: ', num2str(totIndex)]);
   % General simulation parameters:
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

ACarchiveAll{safetyMarginIndex,totIndex} = ACarchive;
ACstateAll{safetyMarginIndex,totIndex} = ACstate;
ACcontrolAll{safetyMarginIndex,totIndex} = ACcontrol;
WPTiAll{safetyMarginIndex,totIndex} = WPTi;
ACmodeAll{safetyMarginIndex,totIndex} = ACmode;

ACsimtime=size(ACarchiveAll{1}, safetyMarginIndex,totIndex);
ACso6time=strcmp({flight.name},flight_pos(a).name);
    if flight(ACso6time).time(end,2)>endtime
        et=endtime;
    else
        et=flight(ACso6time).time(end,2);
    end
    ACso6time=et-flight_pos(a).spawntime;

TimedifAll{safetyMarginIndex,totIndex} = [ACsimtime ACso6time ACsimtime/ACso6time ACsimtime-ACso6time ACsimtime/ACso6time-1]';  

TrafficArchive(a).name = flight_pos(a).name;
TrafficArchive(a).data{safetyMarginIndex, totIndex} = ACarchiveAll{safetyMarginIndex,totIndex};
TrafficArchive(a).tDif{safetyMarginIndex, totIndex} = TimedifAll{safetyMarginIndex,totIndex};
    end
    end
%if intersected is 0 and , copy the data to the other safety margins and adapt TOT time for other members
if intersected ==0 && time_to_EOBT > 0
    for safetyMarginIndex = 1:NumOfSafetyMargins
          %Ova funkcija mijenja vrijeme prema tome koliki je TOT prema razdiobi
          [ACarcho, TOT_increments] = TOT_decrement(ACarchive,time_to_EOBT/60, entrytime);
    for i = 1:NumOfTOT 
          ACwithTOT = ACarcho(:,:,i);
          ACarchiveAll{safetyMarginIndex,i} = ACwithTOT;
          ACstateAll{safetyMarginIndex,i} = ACstate;
          ACcontrolAll{safetyMarginIndex,i} = ACcontrol;
          WPTiAll{safetyMarginIndex,i} = WPTi;
          ACmodeAll{safetyMarginIndex,i} = ACmode;
          
          TimedifAll{safetyMarginIndex,i} = [ACsimtime ACso6time ACsimtime/ACso6time ACsimtime-ACso6time ACsimtime/ACso6time-1]';
%         TrafficArchive(a).name = flight_pos(a).name;
          TrafficArchive(a).data{safetyMarginIndex, i} = ACarchiveAll{safetyMarginIndex,i};
          TrafficArchive(a).tDif{safetyMarginIndex, i} = TimedifAll{safetyMarginIndex,i};
    end
    end
end
if intersected ==0 && time_to_EOBT < 0
    for safetyMarginIndex = 1:NumOfSafetyMargins
        [ACarcho] = TOT_decrementNaN(ACarchive, TOT_time_sec);
         for i = 1:NumOfTOT 
          ACwithTOT = ACarcho(:,:,i);
          ACarchiveAll{safetyMarginIndex,i} = ACwithTOT;
          ACstateAll{safetyMarginIndex,i} = ACstate;
          ACcontrolAll{safetyMarginIndex,i} = ACcontrol;
          WPTiAll{safetyMarginIndex,i} = WPTi;
          ACmodeAll{safetyMarginIndex,i} = ACmode;
          
          TimedifAll{safetyMarginIndex,i} = [ACsimtime ACso6time ACsimtime/ACso6time ACsimtime-ACso6time ACsimtime/ACso6time-1]';
%         TrafficArchive(a).name = flight_pos(a).name;
          TrafficArchive(a).data{safetyMarginIndex, i} = ACarchiveAll{safetyMarginIndex,i};
          TrafficArchive(a).tDif{safetyMarginIndex, i} = TimedifAll{safetyMarginIndex,i};
         end
    end
    toc
end
    end
end
    save(['TA', num2str(batch)], 'TrafficArchive');
    
    clearvars -except flight_pos traffic_batch batch;
    fclose('all');
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
end