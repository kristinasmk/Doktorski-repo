function MathAngle = NavAngleToMathAngle (NavAngle)
% Convert angles such as headings and tracks from air navigation coordinate
%system to math coordinate system.
%
% NavAngle - Angle from north to track or heading line. [degrees]
% Angle measured from X-axis of coord system. [radians]

if (abs(NavAngle) > 360)
    NavAngle = NavAngle-360*round(NavAngle/360);
end

if (NavAngle < 0) 
    NavAngle = NavAngle + 360;
end

if (NavAngle <= 90) % converting new track to math polar coords (from airnav coords)
    NavAngle = 90 - NavAngle;
else
    NavAngle = 450 - NavAngle;
end

MathAngle = NavAngle * 0.0174532925199433; %convert to radians 
    
end