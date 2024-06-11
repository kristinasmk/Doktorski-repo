function [tas] = CAStoTAS(p, rho, CAS)
%CAS to TAS conversion
%
%Inputs:
%p          :pressure in Pa.
%rho        :density in kg/m3
%CAS        :calibrated airspeed m/s
%
%Output:
%tas        :true airspeed m/s.
%
%REF: BADA 3.15      eq. 3.1-23

tas = (2*p/(0.2857*rho)*((1 + (101325/p) * ...
    ((1 + 0.2857*1.225*CAS^2/(2*101325))^3.5 - 1))^0.2857 - 1))^0.5;

end