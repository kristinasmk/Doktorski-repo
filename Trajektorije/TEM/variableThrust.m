function thrust = variableThrust(ROCD, TAS, Drag, Mass, ESF, T, dT, const)
%Calculates needed thrust for given TAS setting and ROCD. 
%
%Inputs:
%       ROCD        - Rate of climb/descent. m/s
%       TAS         - true airspeed, m/s
%       Drag        - Aerodynamic drag. Newtons
%       Mass        - Aircraft mass. Kilograms
%       ESF         - Energy share factor.
%       T           - Air temperature. K
%       dT          - Temperature differential from ISA conditions.
%       const       - Constants
%
%Outputs:
%       Thrust      - Thrust acting parallel to the aircraft velocity vector. Newtons
%
%REF: Bada user manual 3.15 eq. 3.2-7

thrust = Drag + (ROCD / ((T - dT) * ESF * TAS / (Mass * const.g0 * T)));

end