function FuelFlow = FuelConsumption( TAS,  Thrust,  Hp,  Cf1,  Cf2,  Cf3,  Cf4,  Cfcr,ACtype, PhaseOfFlight)
%{
Calculates fuel consumption depending on phase of flight and type of engine. Chapter 3.9 in BADA 3.15.
Returns fuel consumption in kg/sec. Cf1, Cf2, Cf3, Cf4, Cfcr can be found in OPF file.

Inputs:
TAS - True airspeed. [m/s]
Thrust - Thrust. [Newtons]
Hp - Actual aircraft geopotential pressure altitude. [m]
Cf1 - 1st thrust specific fuel consumption coefficient, kg/(min*kN) (jet), kg/(min*kN*kt) (turboprop), kg/min (piston)
Cf2 - 2nd thrust specific fuel consumption coefficient, kts
Cf3 - 1st descent fuel flow coefficient, kg/min
Cf4 - 2nd descent fuel flow coefficient, feet
Cfcr - Cruise fuel flow correction coefficient, dimensionless
ACtype - Aircraft engine type. Must be: 'Piston' or 'P', 'Jet' or 'J', 'Turboprop' or 'P'.
PhaseOfFlight - Phase of flight. Must be: 'D' or 'Descent', 'L' or 'Level', or 'C' or 'Climb'.
Fnom - nominal fuel flow
Fmin - minimum fuel flow
Fcr - cruise fuel flow

Output:
FuelFlow expressed in [kg/s]
%}

TAS = TAS * 1.943844492440605; % m/s to kts
Hp = Hp / 0.3048; % m to ft
switch (ACtype)

    case {'J','Jet','j','jet'}
        eta = Cf1 * (1 + TAS / Cf2);
        Fnom = eta * Thrust/60000; % Thrust is converted from N to kN 
        %and Fnom is devided by 60 to convert flow from kg/min to kg/sec 
        Fmin = Cf3 * (1 - Hp / Cf4) / 60; % division by 60 to cnvert from min to sec
        Fcr = eta * Thrust * Cfcr /60000; % same conversion as for Fnom
        piston = false;

    case {'T','Turboprop','t','turboprop'}
        eta = Cf1 * (1 - TAS / Cf2) * (TAS/1000);
        Fnom = eta * Thrust/60000;
        Fmin = Cf3 * (1 - Hp / Cf4)/60;
        Fcr = eta * Thrust * Cfcr / 600000;
        piston = false;

    case {'P','Piston','p','piston'}
        Fnom = Cf1/60;
        Fmin = Cf3/60;
        Fcr = Cf1 * Cfcr/60;
        piston = true;

    otherwise
        Fnom = -999999999;
        Fmin = -999999999;
        Fcr = -999999999;
        piston = false;
end

switch (PhaseOfFlight)

    case {'Climb','C'}
        FuelFlow = Fnom; % divided by 60 to get fuel flow per second

    case {'Cruise','L','Level'}
        FuelFlow = Fcr;

    case {'Descent','D'}
        if piston
            FuelFlow = Fmin;
        else
            FuelFlow = max(Fnom, Fmin);
        end
    otherwise
        FuelFlow = -999999999;
end


end