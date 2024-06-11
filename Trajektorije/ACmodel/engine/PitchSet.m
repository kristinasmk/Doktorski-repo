function NewPitch = PitchSet (opsdata, GP, ACstate, ACcontrol, DesiredAlt, ESF, AtmHp,const)
% Determines the required pitch angle.
% inputs:
% opsdata - OPF data as loaded by OPFreader
% GP - Global paramethers data as loaded at start
% ACState - Current aircraft state array.
% DesiredAlt - Desired altitude. Altitude of the next waypoint.
% ESF - Energy share factor
% AtmCons - Atmospheric conditions at current altitude
% Htol - Tolerated altitude difference from nominal
% Output:
%Pitch angle in radians
       
 CurrentAlt = ACstate(3); %Renaming these to make code more readable
 CurrentSpd = ACstate(4);
 CurrentPitch = ACcontrol(3);
 Thr = ACcontrol(1);
 CD = ACcontrol(4);
 Mass = ACstate(6);

 dPitchMax = GP.Anmax * 0.3048 / CurrentSpd ; %Maximum allowed pitch change rad/sec

 AltToLevel = 0; %Required altitude change for aircraft to change attitude from current to level

 NSteps = CurrentPitch / dPitchMax; %number of steps required to change from current pitch to level
 NSteps = abs(round(NSteps));

 dAlt =abs(DesiredAlt - CurrentAlt); %altitude difference

if (NSteps == 0)
    AltToLevel = GP.Htol;
else
    
    i=0;
    while i <= NSteps
        AltToLevel = AltToLevel + CurrentSpd * sin(abs(abs(CurrentPitch) - i * dPitchMax)); %sum of all altitude changes
    i=i+1;
    end
end

DesiredPitch = asin((Thr - (CD * opsdata.wingsurf * AtmHp.rho * CurrentSpd * CurrentSpd) / 2) * ESF / (const.g0 * Mass)); %Ideal pitch for climb or descent

if (CurrentAlt < (DesiredAlt-GP.Htol)) %AC is below desired alt

    if (dAlt <= AltToLevel) %AC should start turning horizontal
        if (CurrentPitch >= 0)
            NewPitch = CurrentPitch - dPitchMax;
        else
            NewPitch = CurrentPitch + dPitchMax;
        end
    else %AC should set pitch for climb
        if (CurrentPitch < (DesiredPitch-dPitchMax))
            NewPitch = CurrentPitch + dPitchMax;
        elseif (CurrentPitch > (DesiredPitch+dPitchMax))
            NewPitch = CurrentPitch - dPitchMax;
        else
            NewPitch = DesiredPitch;
        end
    end
elseif (CurrentAlt > (DesiredAlt + GP.Htol)) %AC is above desired alt
    if (dAlt <= AltToLevel) %AC should start turning horizontal
        if (CurrentPitch <= 0)
            NewPitch = CurrentPitch + dPitchMax;
        else
            NewPitch = CurrentPitch - dPitchMax;
        end
    else %AC should set pitch for descent
        if (CurrentPitch < (DesiredPitch - dPitchMax))
            NewPitch = CurrentPitch + dPitchMax;
        elseif (CurrentPitch > (DesiredPitch + dPitchMax))
            NewPitch = CurrentPitch - dPitchMax;
        else
            NewPitch = DesiredPitch;
        end
    end
else %AC is at desired altitude
    if (CurrentPitch < -dPitchMax)
        NewPitch = CurrentPitch + dPitchMax;
    elseif (CurrentPitch > dPitchMax)
        NewPitch = CurrentPitch - dPitchMax;
    else
        NewPitch = 0;
    end

end


end