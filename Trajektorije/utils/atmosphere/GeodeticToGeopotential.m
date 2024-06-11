function [geopotential_alt]=GeodeticToGeopotential(const, geodetic_alt)
%Conversion of geodetic altitude to geopotential.
%Input:
%       const - constants, must contain 'earthradius' in meters 
%       geodetic_alt - geodetic altitude in meters
%
%Output:       
%       geopotential_alt - Returns geopotential altitude in meters. Eq. 2-7 (BADA 3.10)

    geopotential_alt = geodetic_alt * const.earthradius / (const.earthradius + geodetic_alt);

end