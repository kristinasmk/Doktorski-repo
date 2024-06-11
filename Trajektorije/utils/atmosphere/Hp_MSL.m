function Hpmsl = Hp_MSL(const, dP)
%Calculation of geopotential pressure altitude of mean sea level. Eq. 3-22
%
%Inputs:
%       dP - Difference in pressure at sea level from standard pressure (101325 Pa), in Pascals
%
%Output:
%       Hpmsl - geopotential pressure altitude of mean sea level, Pa

a = ((const.P0 + dP) / const.P0)^((-const.BetaT * const.R) / const.g0);
Hpmsl = (const.T0 / const.BetaT) * (a - 1);

end