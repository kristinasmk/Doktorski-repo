function ACnewstate = ACStateUpdate(ACstate, ACcontrol, Wind,  S,  rho,  FF,  CL, const)
%This function updated state of aircraft (ACState) based on aircraft
%control parameters (ACControl), atmosphere data (wind, rho) and aircraft
%parameters.
% Inputs for this function are:
%const - constants
%---- Aircraft states -----
% x - AC position longitude  [DDD.dddd]  ACstate(1)
% y - AC position latitude   [DD.dddd]   ACstate(2)
% h - AC altitude            [m]         ACstate(3)
% TAS - AC true airspeed     [m/s]       ACstate(4)
% hdg - AC heading           [rad]       ACstate(5)
% mass - mass of aircraft    [kg]        ACstate(6)
%----------------------------
%---- Atmosphere data -------
% rho - air density at current AC altitiude [kg/m^3]
%---- Wind components -------
% wx - wind speed in x axis  [m/s]      Wind(1)
% wy - wind speed in y axis  [m/s]      Wind(2)
% wh - wind speed in h axis  [m/s]      Wind(3)
%----------------------------
%---- Aircraft control paramethers -----
% thrust                     [N]        ACcontrol(1)
% bank                       [rad]      ACcontrol(2)
% pitch                      [rad]      ACcontrol(3)
% drag                       [dimensionless]ACcontrol(4)
%----------------------------
%---- Aircraft parameters ---
% S - Reference wing area of the aircraft [m2]
% FF - Fuel consumption [kg/s]
% CL - Lift coefficient [dimensionless]
%Output from function is updateded state of aircraft (ACnewstate)

%calculated flown distance in one second based on TAS (ACstate(5)), pitch
%(ACcontrol(3)) and wind (Wind(1) and Wind(2))

%converting wind componenets to Wind direction (WindDir) and Wind speed
%(WindSpd)
[WindDir,WindSpd] = cart2compass(-Wind(1),-Wind(2));
%windDir must be reversed beacuse this functions just sum v and u vector
%that why components are multiplied by -1

%calculate track and groundspeed (GS) using wind and AC state data
HDG = MathtoNavAngle (ACstate(5));
[track,GS] = ACdrift(HDG,ACstate(4),WindDir,WindSpd);
%GS is in (m/s) and step of simulation is 1 second so it is required to
%change it to km/s for nm2deg to work.
GS=GS/1000; %m/s -> km/s
dist=km2deg(GS); %converting distance covered in 1 second to degrees

%recon is function to calculate new position using current position,
%distance and direction of flight. Result is [lat,lot] of new point
newpoint=reckon(ACstate(2),ACstate(1),dist,track);
%update AC x position
ACnewstate(1) = newpoint(2);
%update AC y position
ACnewstate(2) = newpoint(1);
%update AC h position
ACnewstate(3) = ACstate(3)+ACstate(4)*sin(ACcontrol(3))+Wind(3);
%update AC TAS
ACnewstate(4) = ACstate(4)-((ACcontrol(4)*S*rho*ACstate(4)^2)/(2*ACstate(6)))-...
    const.g0*sin(ACcontrol(3))+ACcontrol(1)/ACstate(6);
%update AC hdg
ACnewstate(5) = ACstate(5)+(CL*S*rho*ACstate(4)*sin(ACcontrol(2)))/(2*ACstate(6));
%update AC mass
ACnewstate(6) = ACstate(6)-FF;

end