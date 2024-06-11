function ThrMaxCr = ThrustMaxCruise(Tmaxcl, Ctcr)
% Calculates the maximum available cruise thrust. [Newtons] eq. 3.7-8>
% inputs:
% Tmaxcl - Maximum thrust in climb. [Newtons]</param>
% Ctcr - Maximum cruise thrust coefficient. [dimensionless]
% Output:
% ThrMaxCr - Maximum possible Thrust in cruise

ThrMaxCr = Tmaxcl * Ctcr;
end