function [track,GS] = Drift (ACstate,Wind)
%New function for AC drift that take into account earth curve.
%inputs:
%---- Aircraft states -----
% x - AC position longitude  [DDD.dddd]  ACstate(1)
% y - AC position latitude   [DD.dddd]   ACstate(2)
% h - AC altitude            [m]         ACstate(3)
% TAS - AC true airspeed     [m/s]       ACstate(4)
% hdg - AC heading           [rad]       ACstate(5)
% mass - mass of aircraft    [kg]        ACstate(6)
%---- Wind components -------
% wx - wind speed in x axis  [m/s]      Wind(1)
% wy - wind speed in y axis  [m/s]      Wind(2)
% wh - wind speed in h axis  [m/s]      Wind(3)

%converting wind componenets to Wind direction (WindDir) and Wind speed
%(WindSpd)

compass2cart(ACstate(,rho)


end