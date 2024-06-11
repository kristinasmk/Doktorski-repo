function CTE = crosstrackerror (lat1, lon1, lat2, lon2, latAC,lonAC)
% Suppose we have a line AB on a unit sphere. We want to find the shortest
%distance from another point, C, to the line AB. In other words, consider 
%the plane defined by A, B, and O (the center of the sphere, also the 
%origin). Let's call this plane P. We are interested in the angle theta 
% between the vector OC and plane P. If the sphere has radius r, the 
% surface distance is simply r*theta.
% % 1. Convert A, B, and C to Cartesian coordinates
% % 2. Computer n, the unit normal vector to the plane defined by A, B, and 
%     O. n is the normalized cross product of OA and OB
% % 3. Consider the Euclidean distance from C to plane P. This distance is 
%     equal to sin(theta), which is mathematically equal to cos(90-theta) 
%         if we define distance such that theta<90
% % 4. cos(90-theta) can also be represented as the dot product of n and OC
% % 5. set steps 3 and 4 equal to each other and solve for theta


% Source:   https://www.mathworks.com/matlabcentral/answers/109361-how-do
%           -i-calculate-the-distance-from-a-point-to-a-line-on-a-sphere-in-matlab


% -----------------------------------------------------------------------------------------------------------
% % MATLAB code segment to implement the above
% % V is an m x 2 matrix where each row is [lat long] of one point whose 
%     distance to AB we wish to calculate
% Convert everything from degrees to radians, then to Cartesian coordinates 
a = deg2rad([lat1 lon1]);
[ax, ay, az] = sph2cart(a(2), a(1), 1);
A = [ax ay az];
 
b = deg2rad([lat2 lon2]);
[bx, by, bz] = sph2cart(b(2), b(1), 1);
B = [bx by bz];
 
c = deg2rad([latAC lonAC]);
[cx, cy, cz] = sph2cart(c(2), c(1), 1);
C = [cx cy cz];
 
% Compute n, the unit normal vector to the plane defined by A, B, and O
n = cross(A, B);
n = n/norm(n);
 
% Find theta for AC distance in radians and degrees
sinTheta = abs(C*n');    % dot product
theta = asin(sinTheta);  % theta is an m x 1 vector containing the angular 
                         %    distance (in radians) from each of the m points 
                         %    in V to line AB
                         % To get surface distance, multiply by radius of
                         % sphere (3440.065)
% Get shortest distance and the index of the corresponding point
CTE = min(theta)*3440.065;

end