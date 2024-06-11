function [Hcross] = CrossAlt(CAS, Ma, dT, const)
%calculates the altitude at which CAS expressed as TAS is equal to Mach
%number expressed as TAS. It is used to determine at which point in climb
%should the crossover from constant CAS climb to constant Mach climb occur.
%
%Inputs:
%       CAS - calibrated airspeed, m/s
%       Ma - Mach number
%       dT - temperature deviation from ISA
%       const - constants
%
%Output:
%       Hcross - crossover altitude, m
%
%REF: BADA Manual 3.15. eq. 3.1-27 and 3.1-28

ptrans = const.P0*((1+((const.kappa-1)/2)*(CAS/const.a0)^2)^(const.kappa/(const.kappa-1))-1)/...
    ((1+((const.kappa-1)*Ma^2)/2)^(const.kappa/(const.kappa-1))-1);

Ttrop = const.T0+dT+const.BetaT*const.Hp_trop;

ptrop = const.P0*(((Ttrop-dT)/const.T0)^(-const.g0/(const.BetaT*const.R)));

if ptrans>=ptrop
   Hcross=(const.T0/const.BetaT)*((ptrans/const.P0)^(-(const.BetaT*const.R)/const.g0)-1);
else
   Hcross=const.Hp_trop-((const.R*const.Tisa_trop)/const.g0)*log(ptrans/ptrop);
end

end