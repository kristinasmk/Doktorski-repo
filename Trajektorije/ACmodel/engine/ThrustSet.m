function Thrust = ThrustSet (GP, opsdata, ACstate, ACcontrol, AtmHp, ACmode, DesTAS, const)
% Determines the required thrust. Returns thrust in Newtons.
% Inputs:
% GP - GPF data as loaded by GPFreaderforBada
% OpsMod - Operations model from the class library.
% opsdata - OPF data as loaded by OPFreaderforBada
% ACState - Current aircraft state array.
% AtmCons - Atmospheric conditions as calculated by ConditionsAtAlt
% ACmode.CL - Climb mode: C, L, D
% ACmode.ACC - Acceleration mode: A, C, D
% Meteo - Meteo data {temp, pressure, windx, wy, wz}
% ACmode.ConfigMode - Aircraft configuration mode which can be (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
% Output:
% Thrust in Newtons.
        
        
 Thrust=-999999;
 TmaxCl = ThrustMaxClimb(ACstate(3), AtmHp.T - 288.15, opsdata.Ctc1, opsdata.Ctc2, opsdata.Ctc3, opsdata.Ctc4, opsdata.Ctc5, ACstate(4), opsdata.engtype);
 Tdes = ThrustInDescent(ACstate(3) / 0.3048, opsdata.Hpdes, TmaxCl, opsdata.Ctdeslow, opsdata.Ctdeshi, opsdata.Ctdesapp, opsdata.Ctdesld, ACmode.ConfigMode);
 TmaxCruise = ThrustMaxCruise(TmaxCl, GP.Ctcr);

 Hmax = MaximumAltitude(opsdata.maxalt,opsdata.Hmax,opsdata.tempgrad, opsdata.gw, AtmHp.T-288.15, opsdata.Ctc4, opsdata.mmax, ACstate(6));
 CTred = ReducedClimbPowerCoeff(Hmax, ACstate(3), opsdata.mmax, opsdata.mmin, ACstate(6), opsdata.engtype, GP);

if (ACmode.CL == 'L' && ACmode.ACC=='C') %Level and Constant
    
     ThrForSpeed = (ACcontrol(4) * opsdata.wingsurf * AtmHp.rho * DesTAS * DesTAS) / 2 + const.g0 * sin(ACcontrol(3)) / (ACstate(6));
    Thrust = ThrForSpeed;
    if (ThrForSpeed > TmaxCruise) 
        Thrust = TmaxCruise;
    end
    
elseif (ACmode.CL == 'L' && ACmode.ACC == 'A') %Level and Accelerating

     ThrForMaxAccel = GP.Almax * 0.3048 * ACstate(6) + (ACcontrol(4) * opsdata.wingsurf * AtmHp.rho * ACstate(4) * ACstate(4)) / 2 + const.g0 * sin(ACcontrol(3)) * ACstate(6);
    Thrust = ThrForMaxAccel;
    if (ThrForMaxAccel > TmaxCruise) 
        Thrust = TmaxCruise;
    end
    
elseif (ACmode.CL == 'L' && ACmode.ACC == 'D') %Level and Decelerating
    
     ThrForMaxDecel = -GP.Almax * 0.3048 * ACstate(6) + (ACcontrol(4) * opsdata.wingsurf * AtmHp.rho * ACstate(4) * ACstate(4)) / 2 + const.g0 * sin(ACcontrol(3)) * ACstate(6);
    Thrust = ThrForMaxDecel;
    if (ThrForMaxDecel > TmaxCruise) 
        Thrust = TmaxCruise;
    end
    
elseif (ACmode.CL == 'C') %Climbing


    if (ACstate(3) < (Hmax * 0.8 * 0.3048))
        Thrust = TmaxCl * CTred;  
    else
        Thrust = TmaxCl;
    end
    
    if (Thrust > TmaxCl) 
        Thrust = TmaxCl;
    end
    
elseif (ACmode.CL == 'D') %Descent

        Thrust = Tdes;

    if (Thrust < 0) 
        Thrust = 0;
    end
end


end