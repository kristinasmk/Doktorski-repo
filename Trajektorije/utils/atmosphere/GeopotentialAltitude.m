function H = GeopotentialAltitude(const, Hp, dT, dP)
%Calculation of Geopotential Altitude based on geopotential pressure altitude, temperature diff, and pressure diff.
%
%Inputs:
%       Hp - Geopotential pressure altitude (meters)
%       dT - Temperature difference from ISA standard temperature at MSL, which is 288.15K. (Kelvins)
%       dP - Difference in pressure at sea level from standard pressure (101325 Pa), in Pascals.
%
%Output:
%       H - geopotential altitude in meters Eq. 3-31

Hpmsl = Hp_MSL(const,dP);
if (Hp < const.Hp_trop)
    H = Hp - Hpmsl + (dT / const.BetaT) * log((const.T0 + const.BetaT * Hp) / (const.T0 + const.BetaT * Hpmsl));
else
    H = const.Hp_trop + (const.T0 + dT + const.BetaT * const.Hp_trop) * (Hp - const.Hp_trop) / (const.T0 + const.BetaT * const.Hp_trop);
end

end
