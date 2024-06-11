function coords = coord_conv (coords_in)
%this function will convert coords from DDMMSSNDDDMMSSE format to 
%DD.dddd N/S DDD.dddd W/E


etime_ch=char(coords_in);     %conversion from text to characters


latside=coords_in(:,7);
lonside=coords_in(:,15);

DD_lat=coords_in(:,1:2);      %parsing deegres
MM_lat=coords_in(:,3:4);      %parsing minutes
SS_lat=coords_in(:,5:6);      %parsing seconds

DDD_lon=coords_in(:,8:10);      %parsing deegres
MM_lon=coords_in(:,11:12);      %parsing minutes
SS_lon=coords_in(:,13:14);      %parsing seconds


DD_lat=str2num(DD_lat);   
MM_lat=str2num(MM_lat);   
SS_lat=str2num(SS_lat);    

DDD_lon=str2num(DDD_lon); 
MM_lon=str2num(MM_lon);      
SS_lon=str2num(SS_lon);    

%converting to DD.ddddd, DDD.ddddd format
lat=DD_lat+MM_lat/60+SS_lat/3600;
lon=DDD_lon+MM_lon/60+SS_lon/3600;

%merging to one string table
coords=[string(lat),string(latside),string(lon),string(lonside)];
end