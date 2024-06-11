function a=SpeedOfSound(const,t)
%Calculation of speed of sound.
% Inputs:
%         t - air temperature (Kelvin)
%         const - constants struct, must contain 'kappa' and 'R'
% 
% Outputs:
%         a - speed of sound in meters/second. Eq. 2-14 BADA 3.10


a = (const.kappa * const.R * t)^0.5;

end