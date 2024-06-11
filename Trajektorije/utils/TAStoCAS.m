function [cas] = TAStoCAS(p, rho, TAS)
%TAS to CAS conversion
%
%Inputs:
%p          :pressure in Pa.
%rho        :density in kg/m3
%TAS        :true airspeed m/s
%
%Output:
%cas        :calibrated airspeed m/s.
%
%REF: BADA 3.15      eq. 3.1-24


cas = (2*101325/(0.2857*1.225) * ((1 + (p/101325) * ...
    ((1 + 0.2857*rho*TAS^2/(2*p))^3.5 - 1))^0.2857 - 1))^0.5;

end