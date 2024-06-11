function CD = DragCoefficient(liftcoefficient, C_D0, C_D2, C_D0dLDG)
%{
Calculation of coefficient of drag per eq. 3.6-2, 3.6-3, and 3.6-4. This method requires appropriate values of C_D0 and C_D2 
to be entered according to the phase of flight (e.g. C_D0CR, C_D0AP, C_D0LDG for cruise, approach and landing respectively).
If C_D0AP, C_D0LDG, C_D2AP, C_D2LDG, and C_D0dLDG are set to 0 in OPF file, cruise coefficients must be used!

liftcoefficient - Coefficient of lift. [dimensionless]
C_D0 - Drag coefficient. [dimensionless]
C_D2 - Induced drag coefficient. [dimensionless]
C_D0dLDG - Drag increase due to landing gear. Set to 0 if not during the landing phase. [dimensionless]

%}

CD = C_D0 + C_D0dLDG + C_D2 * liftcoefficient * liftcoefficient;

end