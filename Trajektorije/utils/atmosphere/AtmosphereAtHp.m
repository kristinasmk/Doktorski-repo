function [T, p, rho, a] = AtmosphereAtHp(Hp, dT, const)
% Calculation of atmospheric conditions at given geopotential pressure altitude
% 
% Inputs:
%         Hp - Geopotential pressure altitude (meters)
%         dT - Temperature difference from ISA standard temperature at MSL, 
%               which is 288.15K. (Kelvins)
%         const - constants struct, must contain BetaT, Hp_trop, R, g
% 
% Outputs:
%         T - temperature at altitude (K). Eq. 3-28, BADA 3.10
%         p - pressure
%         rho - density
%         a - speed of sound

if (Hp < const.Hp_trop)
    T = const.T0 + dT + const.BetaT * Hp;
    p = const.P0*((T-dT)/const.T0)^(-const.g0/(const.BetaT*const.R));
else
    T = const.T0 + dT + const.BetaT * const.Hp_trop;
    PatHptrop = const.P0 * (1 + (const.BetaT * const.Hp_trop) / const.T0)^(-const.g0 / (const.BetaT * const.R));
    p = PatHptrop * exp((-const.g0 / (const.R * const.Tisa_trop)) * (Hp - const.Hp_trop));
end

rho = AirDensity(const, p, T);
a = sqrt(const.kappa*const.R*T);

end