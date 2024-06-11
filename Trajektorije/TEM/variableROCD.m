function ROCD = variableROCD(TAS, Thrust, Drag, Mass, ESF, T, dT, const)
%Calculates rate of climb/descent (dHp/dt) of aircraft for given thrust setting 
%and speed. Returned altitude difference is for geopotential pressure altitude.
%
%Inputs:
%       TAS         - True Air Speed. m/s
%       Thrust      - Thrust acting parallel to the aircraft velocity vector. Newtons
%       Drag        - Aerodynamic drag. Newtons
%       Mass        - Aircraft mass. Kilograms
%       ESF         - Energy share factor.
%       T           - Air temperature. K
%       dT          - Temperature differential from ISA conditions.
%       const       - constants
%
%Outputs:
%       ROCD        - Rate of climb/descent, m/s
%
%REF: Bada user manual 3.15 eq. 3.2-7

ROCD = (T-dT) * ESF * TAS * (Thrust - Drag) / (Mass * const.g0 * T);

end