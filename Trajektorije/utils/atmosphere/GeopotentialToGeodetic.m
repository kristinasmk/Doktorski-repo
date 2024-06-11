function [geodetic_alt]=GeopotentialToGeodetic(const, geopotential_alt)
%Conversion of geopotential altitude to geodetic.
%Input:
%       const - constants, must contain 'earthradius' in meters 
%       geopotential_alt - geopotential altitude in meters
%
%Output:       
%       geodetic_alt - Returns geodetic altitude in meters. Eq. 2-7 (BADA 3.10)

    geodetic_alt = geopotential_alt * const.earthradius / (const.earthradius - geopotential_alt);

end