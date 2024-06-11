
%{
lat=60;
lon=16;
az=90;
arclen=nm2deg(60);


[latout,lonout] = reckon('gc',lat,lon,arclen,az)


%}

lat1=2460/60;
lat2=2820/60;
raster=20;
lat=(lat1*60:raster:lat2*60)';
tic
nlat=numel(lat)
toc
tic
nlat=size(lat,1)
toc