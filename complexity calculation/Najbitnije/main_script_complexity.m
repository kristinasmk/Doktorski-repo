clear all
addpath(genpath('C:\Users\ksamardzic\Documents\Github\Doktorski-repo'));
%This is the main script for complexity calculation

% Explanation of what this script does:
% 1. Loads trajectory prediction data TrafficArchieve
% 2. Loads cloud data
% 3. Creates PRU grid
%4. Samples trajectories to generate traffic scenarios

%load TrafficArchive.mat %pazi koji printa�
load polygons3d.mat; %polygons3d.mat is a product of function nowcast_polygins_final2
load ('C:\Users\ksamardzic\OneDrive - Fakultet prometnih znanosti\Dokumentacija s faksa\Doktorski rad\Matlab Data\nowcast1.mat');
load cloudGrid3D.mat
% load 'C:\Matlab\TrafficArchive.mat';
Clouddata = polygons3d;
SimulationTime =1.5 * 3600;
desired_time=7.75 *3600; %start of simulation
endtime=desired_time+ SimulationTime; %end of simulation
No_weatherScenarios = 15;
NumOfSM =3;

%definition of PRU grid limits
lon1 = 8; %W-E direction
lon2 = 18;
lat2 = 50; %S-N direction
lat1 = 45;
raster = 20;%dimension of one PRU cell, 20NM
Traster = 20; %dimenzija vremena PRU grida

FL1 = 100; %lower and upper limit 
FL2 = 450;

timescale = 0:Traster*60:86400; %cijeli dan

StartTi=find(timescale<=desired_time);
StartTi = StartTi(end); %StartTi is index of starting time for timeframes to reduce size and remove unneeded data
EndTi=find(timescale>=endtime);   %EndTi is index of ending time for timeframes to reduce size and remove unneeded data
EndTi = EndTi(1);

%creation of PRU grid with defined coordinates
[grid, polygon, dims] = gridcreate (lon1,lat1,lon2,lat2,raster,FL1,FL2); %nisam sigurna da je ovo dobro, prebaciti kasnije u kod?

TrafficScenarios_info = {}; %initialization of a variable that will store data about each traffic scenario
cloudGrid3D = cell(1, No_weatherScenarios);

%inserting cloud data into grid
% for i = 1:No_weatherScenarios
%     
% cloudGrid3D{i} = cloudGrid (Clouddata(:,:,i,:),polygon,dims,FL1,FL2,desired_time,endtime,raster, NumOfSM); %izbaciti iz petjle, jednom samo izvrtiti pa kasnije loadati, stavlja oblake u grid
% 
% end
while size (TrafficScenarios_info,1) <= 5000 %stavila sam 5000 ali mora biti neki drugi broj
    
for i = 1:No_weatherScenarios %sampling po weather scenariu
    
%sampling 
[TS, indices, numAircraftTrajectories] = sampling (TrafficArchive, i);


[ACAgrid4D] = ACgridf (TrafficArchive,polygon,dims,Traster,cloudGrid3D(1, i),StartTi,EndTi); %stavlja zrakoplove u grid

Trafficscenario_info = [Trafficscenario_info; {i, indices, numAircraftTrajectories, complexityMax, complexityMax_pos}];

if size(Trafficscenario_info, 1) > 5000
    break;
end

end
end 