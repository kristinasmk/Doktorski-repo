function TAS = variableTAS(ROCD, Thrust, Drag, Mass, ESF, T, dT, const)
%Calculates TAS of aircraft for given thrust setting and ROCD. 
%
%Inputs:
%       ROCD        - Rate of climb/descent. m/s
%       Thrust      - Thrust acting parallel to the aircraft velocity vector. Newtons
%       Drag        - Aerodynamic drag. Newtons
%       Mass        - Aircraft mass. Kilograms
%       ESF         - Energy share factor.
%       T           - Air temperature. K
%       dT          - Temperature differential from ISA conditions.
%       const       - Constants
%
%Outputs:
%       TAS         - true airspeed, m/s
%
%REF: Bada user manual 3.15 eq. 3.2-7

TAS = ROCD/((T - dT) * ESF * (Thrust - Drag) / (Mass * const.g0 * T));

end