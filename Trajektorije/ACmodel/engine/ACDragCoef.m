function DragCoef = ACDragCoef (opsdata, ConfMode, CL)
% Determines the drag coefficient (CD) based on the aircraft configuration and lift coefficient.
% Inputs:
% opsdata - OPF data from opsreader
% ConfMode - Configuration mode as set by ConfigModeSet.
% CL - Lift coefficient. [dimensionless]
% Output:
%Drag coefficient. [dimensionless]
       
    if (string(ConfMode) == 'APP' && opsdata.Cd0.AP ~= 0)
        DragCoef = DragCoefficient(CL, opsdata.Cd0.AP, opsdata.Cd2.AP, 0);
    elseif (string(ConfMode) == 'LDG' && opsdata.Cd0.LD ~= 0)
        DragCoef = DragCoefficient(CL, opsdata.Cd0.LD, opsdata.Cd2.LD, opsdata.Cd0.geardown);
    else
        DragCoef = DragCoefficient(CL, opsdata.Cd0.CR, opsdata.Cd2.CR, 0);
    end
end