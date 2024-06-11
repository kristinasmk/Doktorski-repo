function [subImage,subR] = tifcutf (map_name, filename)
%this function will trim europe geotiff to croatia area
% clear
% map_name = 'testtiff.tif';

[A, R] = geotiffread(map_name);
A=A(:,:,1:3);

row=[441 585];
col=[371 530];

subImage = A(row(1):row(2), col(1):col(2), :);
xi = col + [-.5 .5];
yi = row + [-.5 .5];
[xlimits,ylimits] = intrinsicToGeographic(R,xi,yi);
subR = R;
subR.RasterSize = size(subImage);
subR.LongitudeLimits = sort(xlimits);
subR.LatitudeLimits = sort(ylimits);

info = geotiffinfo(map_name);
% filename = 'test_cro2.tif';
geotiffwrite(filename,subImage,subR, ...
   'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)
%figure
%mapshow(filename)

end