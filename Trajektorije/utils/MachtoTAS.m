function [TAS] = MachtoTAS(T, Ma)
%Mach to TAS conversion
%
%Inputs:
%T          :temp at alt in K
%Ma         :Mach number
%
%Output:
%TAS        :true airspeed m/s
%
%REF: BADA 3.15      eq. 3.1-26

TAS = Ma*(1.4*287.05287*T)^0.5;

end