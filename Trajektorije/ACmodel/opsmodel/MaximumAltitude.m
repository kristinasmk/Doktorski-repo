function maxalt = MaximumAltitude (h_MO, hmax, Gt, Gw, dT, C_tc4, mass_max, mass_actual)
%{
Calculation of maximum altitude for a given actual mass and temperature. 
Aside from dT and actual mass, all parameters are available from the 
aircraft operational file, see class OPFReaderforBADA and BADA 3.15 manual.
Chapter 3.5. section (a). Rerurns altitude in feet.

h_MO - Maximum operating altitude [ft] above standard MSL
hmax - Maximum altitude [ft] above standard MSL at MTOW under 
ISA conditions (allowing about 300 ft/min of residual rate of climb)
Gt - Temperature gradient on hmax [ft/K]
Gw - Mass gradient on hmax [ft/kg] 
dT - Temperature deviation from ISA [K] 
C_tc4 - 1st thrust temperature coefficient, [K]
mass_max - Maximum mass. [kg]
mass_actual - Actual mass. [kg]
%}

a = dT - C_tc4;

if a < 0
    a = 0;
end

b = hmax + Gt * a + Gw * (mass_max - mass_actual);

if hmax == 0
    maxalt = h_MO; %per BADA 3.15 chapter 3.5.
else

    if h_MO < b %the least of two values defines max altitude
        maxalt = h_MO;
    else
        maxalt = b;
    end
end

end