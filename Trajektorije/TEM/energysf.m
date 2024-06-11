function  [esf]=energysf(Ma, T, dt, ACCmode, CLmode, SpeedMode, Tropopause, const)
%Calculates Energy Share Factor as a function of Mach number and climb/acceleration mode.
%
%Inputs:
%   Ma          - Mach number. [dimensionless]
%   T           - Air temperature. [K]
%   dt          - Temperature difference from ISA conditions. [K]
%   ACCmode     - Acceleration mode: (A)ccelerating, (C)onstant, or (D)ecelerating.
%   CLmode      - Climb mode: (C)limb, (L)evel, (D)escent
%   SpeedMode   - Speed mode: (C)AS, (M)ach
%   Tropopause  - Is aircraft above tropopause?(true/false)
%
%Output:
%   esf         - energy share factor
%
%REF: BADA USer manual 3.15 eq. 3.2-8 to 3.2-11

a = (const.kappa * const.R * const.BetaT * Ma * Ma * (T - dt)) / (2 * const.g0 * T);
b = 1 + (const.kappa - 1) * Ma * Ma / 2;

if CLmode == 'L' %Level
    esf = 0; %?
elseif CLmode == 'C' %Climb
    if ACCmode == 'C'  %Constant speed
        if (SpeedMode == 'C' && Tropopause), esf = 1 / (1 + b^(-1 / (const.kappa - 1)) * (b^(const.kappa / (const.kappa - 1)) - 1)); end
        if (SpeedMode == 'C' && ~Tropopause), esf = 1 / (1 + a + b^(-1 / (const.kappa - 1)) * (b^(const.kappa / (const.kappa - 1)) - 1)); end
        if (SpeedMode == 'M' && Tropopause), esf = 1; end
        if (SpeedMode == 'M' && ~Tropopause), esf = 1 / (1 + a); end
    elseif ACCmode == 'A' %Acceleration
        esf = 0.5; %0.3;
    else %Deceleration
        esf = 1.5; %1.7;
    end
else %Descent
    if ACCmode == 'C' %Constant speed
        if (SpeedMode == 'C' && Tropopause), esf = 1 / (1 + b^(-1 / (const.kappa - 1)) * (b^(const.kappa / (const.kappa - 1)) - 1)); end
        if (SpeedMode == 'C' && ~Tropopause), esf = 1 / (1 + a + b^(-1 / (const.kappa - 1)) * (b^(const.kappa / (const.kappa - 1)) - 1)); end
        if (SpeedMode == 'M' && Tropopause), esf = 1; end
        if (SpeedMode == 'M' && ~Tropopause), esf = 1 / (1 + a); end
    elseif ACCmode == 'A' %Acceleration
        esf = 1.5; % 1.7;
    else %Deceleration
        esf = 0.5; % 0.3;
    end
end

end