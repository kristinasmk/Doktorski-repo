function [Ma] = TAStoMach(T, TAS)
%TAS to Mach conversion
%
%Inputs:
%T          :temp at alt in K
%TAS        :true airspeed m/s
%
%Output:
%Ma         :Mach number
%
%REF: BADA 3.15      eq. 3.1-26

Ma = TAS/((1.4*287.05287*T)^0.5);

end