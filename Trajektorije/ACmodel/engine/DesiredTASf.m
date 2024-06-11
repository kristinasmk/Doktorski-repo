function desiredTAS = DesiredTASf (GP,apfdata,opsdata,CLmode,mass,AtmHp,ConfigMode,Hp,TransAlt,const)
% This method returns the desired TAS according to speed schedule as 
%  described in Section 4 of Bada Manual 3.15
% Returns desired TAS in [m/s].
% Inputs:
% GP - GPF data as loaded by GPFreaderforBada
% apfdata - APF data as loaded by APFreaderforBada
% opsdata - OPF data as loaded by OPFreaderforBada
% CLmode - Climb mode: C, L, D
% mass - Current aircraft mass. [kg]
% AtmHp - Atmospheric conditions as calculated by atmosphere model
% ConfigMode - AC configuration from ConfigModeSet (TO, IC, APP, CL, LDG)
% TransAlt - crossover altitude
% Hp - AC altitude [m]
% Output:
%Desired TAS in [m/s]


switch (CLmode)
    case {'C'}
        V_stall_ref = SpeedforMass(opsdata.Vstall.TO, mass, opsdata.mref) / 0.5144;
        
        switch (opsdata.engtype)
            case {'Jet','jet','j','J'}
                VCAS(7) = apfdata.V_cl2.AV; %V_cl2 (ovisi o masi LO,AV,HI)
                VCAS(6) = min(apfdata.V_cl1.AV, 250);
                VCAS(5) = min(GP.Cvmin * V_stall_ref + GP.Vdcl5, VCAS(6));
                VCAS(4) = min(GP.Cvmin * V_stall_ref + GP.Vdcl4, VCAS(5));
                VCAS(3) = min(GP.Cvmin * V_stall_ref + GP.Vdcl3, VCAS(4));
                VCAS(2) = min(GP.Cvmin * V_stall_ref + GP.Vdcl2, VCAS(3));
                VCAS(1) = min(GP.Cvmin * V_stall_ref + GP.Vdcl1, VCAS(2));
                if (Hp < 1500) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(1) * 0.5144);
                elseif (Hp >= 1500 && Hp < 3000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(2) * 0.5144);
                elseif (Hp >= 3000 && Hp < 4000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(3) * 0.5144);
                elseif (Hp >= 4000 && Hp < 5000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(4) * 0.5144);
                elseif (Hp >= 5000 && Hp < 6000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(5) * 0.5144);
                elseif (Hp >= 6000 && Hp < 10000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(6) * 0.5144);
                elseif (Hp >= 10000 && Hp < TransAlt) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(7) * 0.5144);
                elseif (Hp >= TransAlt) 
                    desiredTAS = MachtoTAS(AtmHp.T, apfdata.M_cl.AV);
                end
                
            case {'Turboprop','turboprop','t','T','Piston','piston','p','P'}
                VCASS(5) = apfdata.V_cl2.AV; %V_cl2 (ovisi o masi LO,AV,HI)
                VCASS(4) = min(apfdata.V_cl1.AV, 250);
                VCASS(3) = min(GP.Cvmin * V_stall_ref + GP.Vdcl8, VCASS(4));
                VCASS(2) = min(GP.Cvmin * V_stall_ref + GP.Vdcl7, VCASS(3));
                VCASS(1) = min(GP.Cvmin * V_stall_ref + GP.Vdcl6, VCASS(2));
                if (Hp < 500) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(1) * 0.5144);
                elseif (Hp >= 500 && Hp < 1000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(2) * 0.5144);
                elseif (Hp >= 1000 && Hp < 1500) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(3) * 0.5144);
                elseif (Hp >= 1500 && Hp < 10000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(4) * 0.5144);
                elseif (Hp >= 10000 && Hp < TransAlt) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(5) * 0.5144);
                elseif (Hp >= TransAlt) 
                    desiredTAS = MachtoTAS(AtmHp.T, apfdata.M_cl.AV);
                end
            otherwise
        end
        
    case {'L'}
        switch (opsdata.engtype)
            case {'Jet','jet','j','J'}
                VCAS_(4) = apfdata.V_cr2.AV; %V_cl2 (ovisi o masi LO,AV,HI)
                VCAS_(3) = min(apfdata.V_cr1.AV, 250);
                VCAS_(2) = min(apfdata.V_cr1.AV, 220);
                VCAS_(1) = min(apfdata.V_cr1.AV, 170);
                if (Hp < 3000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS_(1) * 0.5144);
                elseif (Hp >= 3000 && Hp < 6000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS_(2) * 0.5144);
                elseif (Hp >= 6000 && Hp < 14000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS_(3) * 0.5144);
                elseif (Hp >= 14000 && Hp < TransAlt) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS_(4) * 0.5144);
                elseif (Hp >= TransAlt) 
                    desiredTAS = MachtoTAS(AtmHp.T, apfdata.M_cr.AV);
                end
                
            case {'Turboprop','turboprop','t','T','Piston','piston','p','P'}
                VCASa(4) = apfdata.V_cr2.AV;
                VCASa(3) = min(apfdata.V_cr1.AV, 250);
                VCASa(2) = min(apfdata.V_cr1.AV, 180);
                VCASa(1) = min(apfdata.V_cr1.AV, 150);
                if (Hp < 3000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASa(1) * 0.5144);
                elseif (Hp >= 3000 && Hp < 6000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASa(2) * 0.5144);
                elseif (Hp >= 6000 && Hp < 10000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASa(3) * 0.5144);
                elseif (Hp >= 10000 && Hp < TransAlt) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASa(4) * 0.5144);
                elseif (Hp >= TransAlt) 
                    desiredTAS = MachtoTAS(AtmHp.T, apfdata.M_cr.AV);
                end
            otherwise
        end
        
   case {'D'}
        V_stall_ref = SpeedforMass(opsdata.Vstall.LD, mass, opsdata.mref) / 0.5144;
        switch (opsdata.engtype)
            case {'Jet','jet','j','J'}
                VCAS(7) = apfdata.V_des2.AV;
                VCAS(6) = min(apfdata.V_des1.AV, 250);
                VCAS(5) = min(apfdata.V_des1.AV, 220);
                VCAS(4) = min(GP.Cvmin * V_stall_ref + GP.Vddes4, VCAS(5));
                VCAS(3) = min(GP.Cvmin * V_stall_ref + GP.Vddes3, VCAS(4));
                VCAS(2) = min(GP.Cvmin * V_stall_ref + GP.Vddes2, VCAS(3));
                VCAS(1) = min(GP.Cvmin * V_stall_ref + GP.Vddes1, VCAS(2));
                if (Hp < 1000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(1) * 0.5144);
                elseif (Hp >= 1000 && Hp < 1500) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(2) * 0.5144);
                elseif (Hp >= 1500 && Hp < 2000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(3) * 0.5144);
                elseif (Hp >= 2000 && Hp < 3000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(4) * 0.5144);
                elseif (Hp >= 3000 && Hp < 6000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(5) * 0.5144);
                elseif (Hp >= 6000 && Hp < 10000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(6) * 0.5144);
                elseif (Hp >= 10000 && Hp < TransAlt) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCAS(7) * 0.5144);
                elseif (Hp >= TransAlt) 
                    desiredTAS = MachtoTAS( AtmHp.T, apfdata.M_des.AV);
                end
                
            case {'Turboprop','turboprop','t','T','Piston','piston','p','P'}
                VCASS(5) = apfdata.V_des2.AV;
                VCASS(4) = apfdata.V_des1.AV;
                VCASS(3) = min(GP.Cvmin * V_stall_ref + GP.Vddes7, VCASS(4));
                VCASS(2) = min(GP.Cvmin * V_stall_ref + GP.Vddes6, VCASS(3));
                VCASS(1) = min(GP.Cvmin * V_stall_ref + GP.Vddes5, VCASS(2));
                if (Hp < 500) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(1) * 0.5144);
                elseif (Hp >= 500 && Hp < 1000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(2) * 0.5144);
                elseif (Hp >= 1000 && Hp < 1500) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(3) * 0.5144);
                elseif (Hp >= 1500 && Hp < 10000) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(4) * 0.5144);
                elseif (Hp >= 10000 && Hp < TransAlt) 
                    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, VCASS(5) * 0.5144);
                elseif (Hp >= TransAlt) 
                    desiredTAS = MachtoTAS( AtmHp.T, apfdata.M_des.AV);
                end
            otherwise
        end
    otherwise
end

% Check for minimum and maximum allowed speeds.
if strcmp(ConfigMode,'TO')

    V_stall_ref = SpeedforMass(opsdata.Vstall.TO, mass, opsdata.mref);
    SpeedMin = MinimumSpeed(V_stall_ref, GP.Cvmin_to);

elseif strcmp(ConfigMode,'IC')

    V_stall_ref = SpeedforMass(opsdata.Vstall.IC, mass, opsdata.mref);
    SpeedMin = MinimumSpeed(V_stall_ref, GP.Cvmin);

elseif strcmp(ConfigMode,'CL')

    V_stall_ref = SpeedforMass(opsdata.Vstall.CR, mass, opsdata.mref);
    SpeedMin = MinimumSpeed(V_stall_ref, GP.Cvmin);

elseif strcmp(ConfigMode,'APP')

    V_stall_ref = SpeedforMass(opsdata.Vstall.AP, mass, opsdata.mref);
    SpeedMin = MinimumSpeed(V_stall_ref, GP.Cvmin);

elseif strcmp(ConfigMode,'LDG')

    V_stall_ref = SpeedforMass(opsdata.Vstall.LD, mass, opsdata.mref);
    SpeedMin = MinimumSpeed(V_stall_ref, GP.Cvmin);
end

if (Hp > (15000 * 0.3048) && opsdata.engtype == 'Jet') %Low speed buffeting limit below 15000ft for jet aircraft.

    BuffetingLimitMach = JetLowSpeedBuffeting(opsdata.k, opsdata.Clbo,const.g0 * mass, opsdata.wingsurf, AtmHp.p);
    if (SpeedMin < MachtoTAS( AtmHp.T, BuffetingLimitMach)) 
        SpeedMin = MachtoTAS( AtmHp.T, BuffetingLimitMach);
    end
end


if (desiredTAS < SpeedMin) 
    desiredTAS = SpeedMin;
end

if (desiredTAS > CAStoTAS(AtmHp.p, AtmHp.rho, opsdata.VMO* 0.5144)) 
    desiredTAS = CAStoTAS(AtmHp.p, AtmHp.rho, opsdata.VMO* 0.5144);
end

if (desiredTAS > MachtoTAS(AtmHp.T, opsdata.MMO)) 
    desiredTAS = MachtoTAS(AtmHp.T, opsdata.MMO);
end


end