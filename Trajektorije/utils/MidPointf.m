function [MidPoint] = MidPointf (point1, point2)
%this function calculate mid point between two 2D points, for 3D
%calculation see menam matlab function.

%{
original code:
function [latMid, lonMid] = midpointLatLon(lat1, lon1, lat2, lon2)
% midpoint of two lat long cord on a sphere, all units are deg
Bx = cosd(lat2) * cosd(lon2-lon1);
By = cosd(lat2) * sind(lon2-lon1);
latMid = atan2d(sind(lat1) + sind(lat2), ...
               sqrt( (cosd(lat1)+Bx)*(cosd(lat1)+Bx) + By*By ) );
lonMid = lon1 + atan2d(By, cosd(lat1) + Bx);
https://www.mathworks.com/matlabcentral/answers/229312-how-to-calculate-the-middle-point-between-two-points-on-the-earth-in-matlab
%}

    Bx = cosd(point2(1)) * cosd(point2(2)-point1(2));
    By = cosd(point2(1)) * sind(point2(2)-point1(2));
    MidPoint(1) = atan2d(sind(point1(1)) + sind(point2(1)), ...
                   sqrt( (cosd(point1(1))+Bx)*(cosd(point1(1))+Bx) + By*By ) );
    MidPoint(2) = point1(2) + atan2d(By, cosd(point1(1)) + Bx);

end