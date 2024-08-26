function [grids,polygon,dimensions] = gridcreate (lon1,lat1,lon2,lat2,raster,FL1,FL2)
% v2 introduces grid shifts
% this function will build grid for PRU calculations based on fallowing
% inputs:
%   lon1 - longitutde of grid starting point (DDD.dddd)
%   lat1 - latitude of grid starting point   (DD.dddd)
%   lon2 - longitutde of grid ending point (DDD.dddd)
%   lat2 - longitutde of grid ending point (DDD.dddd)
%   FL1 - starting (lowest) flight level of starting point     (### [ft/100])
%   FL2 - last (highest) flight level
%   raster - dimension of squares which will build grid  ( ## [NM])
% ----NOTE----
% Grid is build from lower latitudes towards higher latitudes (when building
% state lower left corner (lon1,lat1) and upper right corner of grid (lon2,lat2))

%since PRU complexity shift grid to compensate for errors caused by
%aircrafts flying close to border fallowing code will crease shift in each
%grid axis. Shift will be done for half of raster size.

%calculating number of grid cells 
lat=(lat1:nm2deg(raster):lat2)';
%shift in lat asix (y)
lat(:,2)=(lat1+nm2deg(raster/2):nm2deg(raster):lat2+nm2deg(raster/2));
grids.lat=lat;

%output of grids.lat is two row set of latitude points for vertex of each
%cell. First row is for defult grid, second row is for shift in latitude
%axis

nlat=size(grids.lat,1); %number of cells in N/S direction

%estimating number of grid cells in E/W axis (works only on one earth half)
lon=(lon1:nm2deg(raster)/cosd(lat1):lon2)'; %this raster is just for 

%grid cells will be build from center to left and right W/E
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
for i=1:2
    for y=1:nlat
        lonr=lon0;  %setting start variables
        lonl=lon0;
        for r=1:right
            [~,lonr]=reckon(grids.lat(y,i),lonr,arclen,azr);
            lonrs(r)=lonr;
            %ovdje treba dalje izraèunavati x koordinatu
        end
        for l=1:left
            [~,lonl]=reckon(grids.lat(y,i),lonl,arclen,azl);
            lonls(l)=lonl;
        end
        loni=sort([lonrs,lon0,lonls]);
        lon(y,:)=loni;
    end
   lont(:,:,i)=lon; 
end
lont(:,:,3)=lont(:,:,1)+nm2deg(raster/2);
lont(:,:,4)=lont(:,:,2)+nm2deg(raster/2);

grids.lon=flip(lont); %lon is 2d matrix, each line represents lon coordinates for
% one latitude coordinate in lat variable
grids.lat=flip(grids.lat);

alt(:,1)=FL1:30:FL2; %defining altitude dimension with step of 3000 feet
%starting from desired flight leve FL1 up to desired flight level FL2
%grid shift in vertical plane is 1000ft which is 10 flight levels.
alt(:,2)=FL1+10:30:FL2+10;
alt(:,3)=FL1+20:30:FL2+20;
grids.alt=alt*0.3048;  %alt is converted from ft to meters




%sp will be shift pattern for cration of different shif polygons
sp=[1,1;1,3;2,2;2,4];
%polygon of each cell is defined with x and y coordinates
for s=1:size(sp,1)
    %this part will create each grid cell as polygon
    ypoly=[];
    xpoly=[];
    
    for y=1:size(grids.lat,1)-1
        ypoint=[grids.lat(y,sp(s,1)),grids.lat(y,sp(s,1)),...
            grids.lat(y+1,sp(s,1)),grids.lat(y+1,sp(s,1)),...
            grids.lat(y,sp(s,1)),NaN];
       for x=1:size(grids.lon,2)-1
           xpoint=[grids.lon(y,x,sp(s,2)),grids.lon(y,x+1,sp(s,2)),...
               grids.lon(y+1,x+1,sp(s,2)),grids.lon(y+1,x,sp(s,2)),...
               grids.lon(y,x,sp(s,2)),NaN];
           %each polygon coordinates are merged to one array
           ypoly=[ypoly,ypoint];
           xpoly=[xpoly,xpoint];
       end
    end
    ypolygons(s,:)=ypoly;
    xpolygons(s,:)=xpoly;
end
polygon.yaxis=ypolygons;
polygon.xaxis=xpolygons;

%dimension is size of grid in x and y axis (cell numeration)
%first number is vertical number of cells (lat raster), and second is
%horisontal (lon raster)
dimensions=[nlat-1,left+right];
end

