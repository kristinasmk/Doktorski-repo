function CL = LiftCoefficient(mass, airdensity, wingarea, TAS, bankangle, const)
%{
Calculation of coefficient of lift per eq. 3.6-1.

mass - Aicraft mass.[kg]
airdensity - Air density [kg/m3]
wingarea - Area of wings [m2]
TAS - True air speed [m/s]
bankangle - Bank angle [radians]
%}

CL = (2 * mass * const.g0) / (airdensity * TAS * TAS * wingarea * cos(bankangle));

end