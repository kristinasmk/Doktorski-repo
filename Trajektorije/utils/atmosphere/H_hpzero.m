function Hhpzero=H_hpzero(const, dP, dT)
%Calculation of geopotential altitude where geopotential pressure altitude is 0.
%
%Inputs:
%       dT - Temperature difference from ISA standard temperature at MSL, which is 288.15K. (Kelvins)
%       dP - Difference in pressure at sea level from standard pressure (101325 Pa), in Pascals.
%
%Output:
%       Hhpzero - geopotential altitude in meters (double). Eq. 3-19 BADA
%       atmosphere model

Hpmsl = Hp_MSL(const,dP);
T_ISAMSL = const.T0 + const.BetaT * Hpmsl;
Hhpzero = (1/const.BetaT)*(const.T0-T_ISAMSL + dT*log(const.T0/T_ISAMSL));

end