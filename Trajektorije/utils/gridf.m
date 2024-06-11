function [grids,polygon,dimensions] = gridf (lon1,lat1,lon2,lat2,raster,FL1,FL2)
addpath(genpath(fileparts(pwd)))
constants
% this function will build grid for PRU calculations based on fallowing
% inputs:
%   lon1 - longitutde of grid starting point (DDD.dddd)
%   lat1 - latitude of grid starting point   (DD.dddd)
%   lon2 - longitutde of grid ending point (DDD.dddd)
%   lat2 - longitutde of grid ending point (DDD.dddd)
%   FLs - flight level of starting point     (### [ft/100])
%   raster - dimension of squares which will build grid  ( ## [NM])
% ----NOTE----
% Grid is build from lower latitudes towards higher latitudes (when building
% state lower left corner (lon1,lat1) and upper right corner of grid (lon2,lat2))


%calculating number of grid cells 
grids.lat=(lat1:nm2deg(raster):lat2)';
nlat=size(grids.lat,1); %number of cells in N/S direction
lon=(lon1:nm2deg(raster)/cosd(lat1):lon2)'; %this raster is just for 
%estimating number of grid cells in E/W axis (works only on one earth half)

%grid cells will be build crom center to left and right W/E
%to do that it is required to calculate number of cells to right and left
right=round(size(lon,1)/2);
left=size(lon,1)-right;
azr=090; %createing of azimuth direction for building cells
azl=270;
lonrs=zeros(1,right);
lonls=zeros(1,left);
arclen=nm2deg(raster);
lon=zeros(nlat,left+right+1);
lon0=(lon1+lon2)/2;
%calculating longitude coordinate for every latitude with raster
    for y=1:nlat
        lonr=lon0;  %seffing start variables
        lonl=lon0;
        for r=1:right
            [~,lonr]=reckon(grids.lat(y),lonr,arclen,azr);
            lonrs(r)=lonr;
            %ovdje treba dalje izraèunavati x koordinatu
        end
        for l=1:left
            [~,lonl]=reckon(grids.lat(y),lonl,arclen,azl);
            lonls(l)=lonl;
        end
        lont=sort([lonrs,lon0,lonls]);
        lon(y,:)=lont;
    end
grids.lon=flip(lon); %lon is 2d matrix, each line represents lon coordinates for
% one latitude coordinate in lat variable
grids.lat=flip(grids.lat);

alt=FL1:10:FL2; %defining altitude dimension with step of 1000 feet
%starting from desired flight leve FL1 up to desired flight level FL2
alt=alt';
grids.alt=alt*const.ft;  %alt is converted from ft to meters

%this part will create each grid cell as polygon
ypoly=[];
xpoly=[];
%polygon of each cell is defined with x and y coordinates
for y=1:size(grids.lat)-1
    ypoint=[grids.lat(y),grids.lat(y),grids.lat(y+1),...
        grids.lat(y+1),grids.lat(y),NaN];
   for x=1:size(grids.lon,2)-1
       xpoint=[grids.lon(y,x),grids.lon(y,x+1),grids.lon(y+1,x+1),...
           grids.lon(y+1,x),grids.lon(y,x),NaN];
       %each polygon coordinates are merged to one array
       ypoly=[ypoly,ypoint];
       xpoly=[xpoly,xpoint];
   end
end
polygon.yaxis=ypoly;
polygon.xaxis=xpoly;

%dimension is size of grid in x and y axis (cell numeration)
dimensions=[nlat-1,left+right];
end

