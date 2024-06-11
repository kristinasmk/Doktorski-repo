function sfm = SpeedforMass (Vref, mass, massref)
%{
Calculation of actual speed for reference speed, reference mass and actual mass, per Eq. 3.4-1

Vref - Reference speed. Any speed unit. (double)
mass - Actual aircraft mass. kg (double)
massref - Reference aircraft mass as extracted from OPF file. kg (double)
%}

sfm = Vref*sqrt(mass/massref);

end