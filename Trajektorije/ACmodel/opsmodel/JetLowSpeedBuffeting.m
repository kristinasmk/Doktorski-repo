function Mb = JetLowSpeedBuffeting( BuffGradK,  C_Lbo,  weight,  wingarea,  pressure)
%{

Calculates low speed buffeting limit for jet aircraft. Above 15000ft low speed buffeting limit may limit the minimum
airspeed. It should be compared with minimum aircraft speed (eq. 3.5-2); the larger of which is the minimum speed.
Returns low speed buffeting limit as MACH number.

BuffGradK - Lift coefficient gradient. [dimensionless]
C_Lbo - Initial buffet onset lift coefficient for M=0. [dimensionless] 
weight - Aircraft weight. [N] 
wingarea - Wing reference area [m2] 
pressure - Actual air pressure. [Pa]
%}

 a1 = -C_Lbo / BuffGradK;
 a3 = (weight / wingarea) / (0.583 * pressure * BuffGradK);

 Q = -(a1 * a1) / 9;
 R = (-27 * a3 - 2 * (a1 * a1* a1)) / 54;

 theta = acos(R / (sqrt(-power(Q, 3))));

 X1 = 2 * sqrt(-Q) * cos(theta / 3) - a1 / 3;
 X2 = 2 * sqrt(-Q) * cos(theta / 3 + 120 * 0.0174532925) - a1 / 3;
 X3 = 2 * sqrt(-Q) * cos(theta / 3 + 240 * 0.0174532925) - a1 / 3;

if X1 < 0
    Mb = min(X2, X3);
else
    if X2 < 0
        Mb = min(X1, X3);
    else
        Mb = min(X1, X2); 
    end
end


end