function Cpowered = ReducedClimbPowerCoeff( hmax,  Hp,  m_max,  m_min,  m_act, ACtype, GP)
%{

Calculates the reduced climb power coefficient that should be used according to eq. 3.8-2 (BADA 3.15).

hmax - Maximum altitude, available from MaximumAltitude. [feet]
Hp - Aircraft actual geopotential pressure altitude. [feet]
m_max - Maximum mass, available from OPF file. [kg]
m_min - Minimum mass, available from OPF file. [kg]
m_act - Actual mass. [kg]
ACtype - Aircraft engine type. P or Piston, J or Jet, T or Turboprop. 

%}

if Hp < hmax * 0.8

    switch (ACtype)
    
        case {'P','Piston'}
            Cred = GP.Cred_pis;

        case {'T','Turboprop'}
            Cred = GP.Cred_tprop;

        case {'J','Jet'}
            Cred = GP.Cred_jet;

        otherwise
            Cred = -999999999;
    end

else

    Cred = 0;
end

Cpowered = 1 - Cred * (m_max - m_act) / (m_max - m_min);
end