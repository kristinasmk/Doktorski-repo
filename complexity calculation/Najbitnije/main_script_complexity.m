clear
%This is the main script for complexity calculation

% Explanation of what this script does:
% 1. Loads trajectory prediction data TrafficArchieve
% 2. Loads cloud data
% 3. Creates PRU grid ...

load polygons3d.mat; %polygons3d.mat is a product of function nowcast_polygins_final2
Clouddata = polygons3d;
SimulationTime = 2.5 * 3600;
desired_time=8*3600; %start of simulation
endtime=desired_time+ SimulationTime; %end of simulation

%definition of PRU grid limits
lon1 = 9; %W-E direction
lon2 = 18;
lat2 = 50; %S-N direction
lat1 = 45;
raster = 20;%dimension of one PRU cell, 20NM
FL1 = 100; %lower and upper limit 
FL2 = 450;

%creation of PRU grid with defined coordinates
[grid, polygon, dims] = gridcreate (lon1,lat1,lon2,lat2,raster,FL1,FL2);

%inserting cloud data into grid
[cloudGrid3D] = cloudGrid (Clouddata,polygon,dims,FL1,FL2,desired_time,endtime,raster);
