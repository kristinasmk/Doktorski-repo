function ConfigMode = ConfigModeSet (GP, opsdata, Hp, CAS, CLmode)
% Determines the aircraft configuration mode which can be 
% (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G).
% Reflects standards from p. 19. of BADA Manual 3.15 (section 3.5)
% Input:
%   GP - Global Parameters data as loaded in mainsim from GlobalParameters.m 
%   opsdata - OPF data as imported by readOPFfile function
%   Hp - Geopotential pressure altitude. [m] 
%       in code.
%   CAS - Calibrated airspeed. [m/s]
%   CLmode - Climb mode: C, L, D
% output:
% a/c configuration mode

ConfigMode = 'ERR';
VminCR = GP.Cvmin * opsdata.Vstall.CR;
VminAP = GP.Cvmin * opsdata.Vstall.AP;


    if CLmode == 'C'

        if (Hp < (GP.Hmax_to * 0.3048))
            ConfigMode = 'TO';
        elseif (Hp >= (GP.Hmax_to * 0.3048) && Hp < (GP.Hmax_ic * 0.3048))
            ConfigMode = 'IC';
        else
            ConfigMode = 'CL';
        end

    elseif CLmode == 'L'
        ConfigMode = 'CL';
    else
        if (Hp < (GP.Hmax_ld * 0.3048) && CAS < (VminAP +10))
            ConfigMode = 'LDG';
        elseif (Hp < (GP.Hmax_ap * 0.3048) && Hp >= (GP.Hmax_ld * 0.3048) && CAS < (VminCR + 10))
            ConfigMode = 'APP';
        elseif (Hp <= (GP.Hmax_ld * 0.3048) && CAS < (VminCR + 10) && CAS >= (VminAP + 10))
            ConfigMode = 'APP';
        elseif (Hp >= (GP.Hmax_ap * 0.3048))
            ConfigMode = 'CL';
        elseif (Hp < (GP.Hmax_ap * 0.3048) && CAS >= (VminCR + 10))
            ConfigMode = 'CL';
        end
    end


end