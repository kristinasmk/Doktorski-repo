function minspd = MinimumSpeed(Vstall, C_Vmin)
%{
Calculation of minimum aircraft speed. For jet aircraft flying above 15000 
feet low speed buffeting limit should also be considered (section 3.5. (b)). Eq. 3.5-2 and 3.5-3

Vstall - Stall speed for given phase of flight. Available in 
OPF file and defined in section 3.5 of BADA. [any speed unit]
C_Vmin - Minimum speed coefficient. Refer to BADA 
section 5.7 for values. Usually 1.2 for take-off and 1.3 otherwise.

%}

minspd = C_Vmin * Vstall;

end