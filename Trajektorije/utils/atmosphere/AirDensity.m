function rho = AirDensity(const, p, T)
%Calculation of air density for given pressure and temperature. 
%
%Inputs:
%       T - air temp (K)
%       p - air pressure (Pa)
%
%Output:
%       rho - air density in kg/m3. Eq. 2-14 BADA ATmosphere model

rho = p / (const.R * T);

end
