function Tmaxcl = ThrustMaxClimb( Hp,  dT,  C_Tc1,  C_Tc2,  C_Tc3,  C_Tc4,  C_Tc5,  TAS, EngType)
%{

Calculates maximum thrust in climb per chapter 3.7.1. Returns thrust in Newtons. 5 Thrust coefficients are
available from OPF file.

Hp - Geopotential pressure altitude. [meters]
dT - Temperature deviation from standard atmosphere. [K] or [C]
C_Tc1 - 1st max climb thrust coefficient, Newton (jet/pist), ktN (turboprop)
C_Tc2 - 2nd max climb thrust coefficient, ft
C_Tc3 - 3rd max climb thrust coefficient, 1/ft2 (jet), kt*Newton (pist), N (turboprop)
C_Tc4 - 1st thrust temperature coefficient, K
C_Tc5 - 2nd thrust temperature coefficient, 1/K
TAS - True air speed. May be 0 for jet aircraft. [m/s]
EngType - Engine type. Jet, Turboprop, Piston. Also valid: J, T, P; or: j,t,p. 
%}

Hp = Hp / 0.3048;
TAS = TAS * 3600 / 1852;

switch (EngType)
    case {'Jet','jet','j','J'}
        TmaxclISA = C_Tc1 * (1 - Hp / C_Tc2 + C_Tc3 * Hp * Hp);
        
    case {'Turboprop','turboprop','t','T'}
        TmaxclISA = (C_Tc1/TAS) * (1 - Hp / C_Tc2) + C_Tc3;
        
    case {'Piston','piston','p','P'}
        TmaxclISA = C_Tc1 * (1 - Hp / C_Tc2) + C_Tc3/TAS;
      
    otherwise
        TmaxclISA = -99999999999999;
end
        
dTeff = dT - C_Tc4;

if C_Tc5 < 0
    C_Tc5 = 0;
end

a = dTeff * C_Tc5;
if a < 0
    a = 0;
end
if a > 0.4
    a = 0.4;
end

 Tmaxcl = TmaxclISA * (1 - a);

end