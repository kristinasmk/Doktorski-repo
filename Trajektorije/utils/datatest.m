%this code was used to transform the shapefile into a very long line which
%is then used for plotting. this method increases speed of plotting by more
%than 10 times. this code can be reused when different shapefile needs to
%be transformed.

%this code expects a variable named 'a' which contains the shapefile

lats = a(1).X;
lons = a(1).Y;

for i = 2:54 %adjust number of pairs of vectors of coordinates
    lats = [lats nan a(i).X];
    lons = [lons nan a(i).Y];
end

lats = lats(:);
lons = lons(:);

