function p=PressureAtHp(const, Hp)
%Calculation of air pressure at given geopotential pressure altitude.
%
%Inputs:
%       Hp - Geopotential pressure altitude (meters)
%       const - constants struct, must contain BetaT, Hp_trop, R, g
%
%Outputs:
%       p - pressure in Pascals. Eq. 3-26

if Hp < const.Hp_trop
    a = (1 + (const.BetaT*Hp)/const.T0);
    b = -const.g0/(const.BetaT*const.R);
    p = const.P0 * a^b; 
else
    PatHptrop = const.P0 * (1 + (const.BetaT * const.Hp_trop) / const.T0)^(-const.g0 / (const.BetaT * const.R));
    p = PatHptrop * exp((-const.g0 / (const.R * const.Tisa_trop)) * (Hp - const.Hp_trop));
end

end