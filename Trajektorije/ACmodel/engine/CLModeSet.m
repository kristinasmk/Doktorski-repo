function Cmode = CLModeSet (h,h_desired, CLmode, Htol)
%Determines the climb mode which can be (C)limb, (L)evel, and (D)escent.
%Prevents instantaneous switching from climb mode to descent and vice versa.
%input:
% h - Current geodetic altitude. [m]
% h_desired - Desired geodetic altitude. [m]
% CLmode - Current climb mode.
% Htol - tolerance from desired altitude in which mode will not be changed
% output:
%Climb mode which can be: (C)limb, (L)evel, and (D)escent.</returns>

    if h < (h_desired - Htol) %Current altitude is lower than desired altitude
        if CLmode == 'C' || CLmode == 'L' %prevents instantly switching from climb to descent
            Cmode = 'C';
        else
            Cmode = 'L';
        end
    elseif (h > (h_desired + Htol))
        if CLmode == 'D' || CLmode == 'L'
            Cmode = 'D';
        else
            Cmode = 'L';
        end
    else
        Cmode = 'L';
    end
end