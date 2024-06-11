function Tatalt = Temp_at_alt(const, Hp, dT)
% Calculation of air temperature at given geopotential pressure altitude.
% 
% Inputs:
%         Hp - Geopotential pressure altitude (meters)
%         dT - Temperature difference from ISA standard temperature at MSL, 
%               which is 288.15K. (Kelvins)
% 
% Outputs:
%         Tatalt - temperature at altitude (K). Eq. 3-28, BADA 3.10

if (Hp < const.Hp_trop)
    Tatalt = const.T0 + dT + const.BetaT * Hp;
else
    Tatalt = const.T0 + dT + const.BetaT * const.Hp_trop;
end
end



%  /// <summary>
%         /// Calculation of air temperature at given geopotential pressure altitude. Returns temperature in Kelvins (double). Eq. 3-28
%         /// </summary>
%         /// <param name="Hp">Geopotential pressure altitude (meters)</param>
%         /// <param name="dT">Temperature difference from ISA standard temperature at MSL, which is 288.15K. (Kelvins)</param>
%         public double TempAtAlt(double Hp, double dT)
%         {
%             double Tatalt;
%             if (Hp < Hp_trop)
%             {
%                 Tatalt = T0 + dT + BetaT * Hp;
%             }
%             else
%             {
%                 Tatalt = T0 + dT + BetaT * Hp_trop;
%             }
%             return Tatalt;
%         }