function NavAngle = MathtoNavAngle (MathAngle)
%Convert angles such as headings and tracks from math coord system to air nav coord system.
% MathAngle - Angle with x-axis. [radians]
% Air nav angle measured from north clockwise. [degrees]

NavAngle = MathAngle * 57.29577951308233;

NavAngle = -NavAngle + 90;

if (abs(NavAngle) > 360)
    
     NavAngle = NavAngle-360*round(NavAngle/360); %bounding the value of HdgDiff to +/-360
end
    
if (NavAngle < 0) 
    
    NavAngle = NavAngle + 360;
end
    
    
