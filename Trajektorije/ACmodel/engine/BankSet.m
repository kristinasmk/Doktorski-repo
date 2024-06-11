function NewBank = BankSet (GP, ACstate, ACcontrol, waypoints, WPTi,ConfMode, Wind, const)
% This is a bank angle controller that assumes that an aircraft can be at a significant distance from the desired track.
% First, cross-track error is calculated and from it a required heading for intercepting the desired track is calculated.
% Then, bank angle is adjusted in such way that the aircraft is heading in the required direction (i.e. intercept heading).
% Intercept heading is initially perpendicular to the track, but as aircraft closes in on the track it reduces gradually.
% Final intercept heading is equal to the desired heading which is equal to track corrected for wind correction angle.
% Crude numerical integration is employed to calculate the lead angle at which the aircraft needs to start rolling out
% of the turn in order to exit the turn in the right heading. Undoubtedly there is a lot of room for improvement in this regard
% and in the controller as a whole.
%%Bank angle controller. Returns new bank angle in radians.
%Inputs:
% GP - GPF data as loaded by GPFreaderforBada
% ACState - Current aircraft state array.
% waypoints - Waypoints as loaded in the WPT struct
% WPTi - Current waypoint index
% ConfMode - Configuration mode as set by ConfigModeSet.
% Holding - Holding mode.
% Meteo - Meteo data {temp, pressure, windx, wy, wz}
%<Output:
%New bank angle in radians.



            

CurrentX = ACstate(1); %renamed for readability
CurrentY = ACstate(2);
CurrentSpd = ACstate(4);
CurrentHdg = ACstate(5);
CurrentBank = ACcontrol(2);

% %2PI?
% if (abs(CurrentHdg) > pi*2) %2PI or not 2PI?
%     CurrentHdg = CurrentHdg-pi*2*round(CurrentHdg/(pi*2)); %bounding the value of HdgDiff to +/-Pi
% end

%Track - Track from previous waypoint to the next.
%DirectTo - Track direct from ac position to next waypoint
%CTE - Cross-track error
%BankMax - Maximum allowed bank angle
DirectTo = azimuth(CurrentY, CurrentX,waypoints(WPTi).y,waypoints(WPTi).x);
DirectTo = NavAngleToMathAngle (DirectTo);

% Track = azimuth(waypoints(WPTi-1).y,waypoints(WPTi-1).x,waypoints(WPTi).y,waypoints(WPTi).x);
Track=DirectTo;
%correcting tas from navigation angles to mathematics 
% Track=NavAngleToMathAngle (Track);

CTE = crosstrackerror (waypoints(WPTi-1).y,waypoints(WPTi-1).x, waypoints(WPTi).y,waypoints(WPTi).x, CurrentY, CurrentX);

if strcmp(ConfMode,'TO')
  BankMax = GP.phi_nom_to * pi/180;
else
  BankMax = GP.phi_nom_oth * pi/180; 
end


TurnRadius = CurrentSpd * CurrentSpd / (const.g0 * tan(BankMax));
RelativeDist = CTE / TurnRadius;

WindDir = atan2(Wind(2), Wind(1));
WindSpd = sqrt(Wind(1) * Wind(1) + Wind(2) * Wind(2));
WCA = asin(sin(Track - WindDir) * WindSpd / CurrentSpd);
DesiredHdg = Track + WCA;
%{
% InterceptHdg Heading that will intercept the track corrected for wind (DesiredHdg).

if (RelativeDist > 0.01)
    InterceptHdg = DesiredHdg - min(45* abs(RelativeDist), 90)*pi/180;
elseif (RelativeDist < -0.01)
    InterceptHdg = DesiredHdg + min(45 * abs(RelativeDist), 90) * pi / 180;
else
    InterceptHdg = DesiredHdg;
end
%}
InterceptHdg = DirectTo + WCA; %THIS LINE makes the aircraft fly straight from current position towards next point.
%It makes the previous calculation of the intercepthdg obsolete.
%By removing this line the aircraft will fly along the reference line from one waypoint to the other. 

NSteps = CurrentBank / 0.034906585; %number of steps required to change from current bank to 0° (step is 2°/s)
NSteps = abs(round(NSteps));

sum_turn = 0;
%Lead heading is actually heading difference at which ac needs to start rolling out of the turn in order to roll out at desired hdg.

if (NSteps == 0)
    LeadHdg = 0;
else
    if (CurrentBank > 0)
        i=0;
        while i <= NSteps
            sum_turn = sum_turn + tan(CurrentBank - 0.034906585 * i); %sum of tans
        i=i+1;
        end
    else
        i=0;
        while i <= NSteps
            sum_turn = sum_turn + tan(CurrentBank + 0.034906585 * i); %sum of tans
        i=i+1;
        end
    end    
    LeadHdg = const.g0 * sum_turn / CurrentSpd;
end

HdgDiff = InterceptHdg - CurrentHdg;

if (abs(HdgDiff) > pi*2) %2PI or not 2PI?
    HdgDiff = HdgDiff-pi*2*round(HdgDiff/(pi*2)); %bounding the value of HdgDiff to +/-Pi
end

if (sin(HdgDiff) > 0)
    DirectionLeft = true;
else
    DirectionLeft = false;
end


NewBank = 0;
if (DirectionLeft && CurrentBank < 0) %AC is banking right and it should turn left
    NewBank = CurrentBank + 0.034906585; %0.034906585 is 2° in radians (2°/s is selected maximum bank angle change)
elseif (~DirectionLeft && CurrentBank > 0) %AC is banking left and it should turn right
    NewBank = CurrentBank - 0.034906585;
else
    if (DirectionLeft && HdgDiff > LeadHdg)
        NewBank = CurrentBank + 0.034906585;
    elseif (DirectionLeft && HdgDiff <= LeadHdg)
        if (HdgDiff < 0)
            NewBank = CurrentBank + 0.034906585;
        else
            NewBank = CurrentBank - 0.034906585;
        end
    elseif (~DirectionLeft && HdgDiff < LeadHdg || ~DirectionLeft && HdgDiff > pi)
        NewBank = CurrentBank - 0.034906585;
    elseif (~DirectionLeft && HdgDiff >= LeadHdg)
        NewBank = CurrentBank + 0.034906585;

    end

if (abs(NewBank) > BankMax)
    if (NewBank > 0)
        NewBank = NewBank - 0.034906585;
    else
        NewBank = NewBank + 0.034906585;

    end

end

end