function ACmode = ACCModeSet (TAS,desiredTAS,ACCmode,Vtol)
% Determines the acceleration mode which can be (A)ccelerate, (C)onstant, and (D)eccelerate.
% Prevents instantaneous switching from acceleration mode to decceleration and vice versa.
% Inputs:
% TAS - True airspeed. [m/s]
% desiredTAS - Desired true airspeed. [m/s]
% ACCmode - Current acceleration mode.
% Output 
% Acceleration mode as: (A)ccelerate, (C)onstant, and (D)eccelerate. String.


    if ( TAS < (desiredTAS - Vtol)) %Current TAS is lower than desired Tas
        
        if (ACCmode == 'C' || ACCmode == 'A') %prevents instantly switching from decceleration to acceleration
            ACmode = 'A';
        else
            ACmode = 'C';
        end
        
    elseif (TAS > (desiredTAS + Vtol))
        
        if (ACCmode == 'C' || ACCmode == 'D')
            ACmode = 'D';
        else
            ACmode = 'C';
        end
        
    else
        
        ACmode = 'C';
    end

end