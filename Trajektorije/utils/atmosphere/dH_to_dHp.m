function dHp=dH_to_dHp(const, dH, dT)
%Calculates the geopotential pressure altitude difference from geopotential
%altitude difference and temperature differential. Eq. 3-14
% 
% Inputs:
%         dH - Geopotential altitude difference in meters
%         dT - Temperature difference from ISA standard temperature at MSL, which is 288.15K. (Kelvins)
%         
% Output:
%         dHp - geopotential pressure altitude difference (m)
    
     T_ISA = const.T0 + dH * const.BetaT;
     T = const.T0 + dT + dH * const.BetaT;
     dHp = (T_ISA / T) * dH;
end

