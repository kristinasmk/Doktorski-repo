function TiD = ThrustInDescent(Hp, Hpdes, Tmaxcl, C_Tdeslow, C_Tdeshigh, C_Tdesapp, C_Tdesld, Configuration)
%{

Calculates thrust in descent. Returns thrust in Newtons. Parameters Hpdes, C_Tdeslow, C_Tdeshigh, C_Tdesapp, C_Tdesld are available from OPF file.

Hp - Actual geopotential pressure altitude of the aircraft in FEET!
Hpdes - Transition altitude for calculation of descent thrust, feet
Tmaxcl - Maximum thrust in climb. [Newtons]
C_Tdeslow - Low altitude descent thrust coefficient, dimensionless
C_Tdeshigh - High altitude descent thrust coefficient, dimensionless
C_Tdesapp - Approach thrust coefficient, dimensionless
C_Tdesld - Landing thrust coefficient, dimensionless
Configuration - Aircraft configuration distinguishes three descent states: (CL)ean, (APP)roach, (L)an(D)in(G).

%}

if Hp > Hpdes
    TiD = C_Tdeshigh * Tmaxcl;
else
    switch (Configuration)
        case {'CL','Clean'}
            TiD = C_Tdeslow * Tmaxcl;

        case {'APP','Approach'}
            TiD = C_Tdesapp * Tmaxcl;

        case {'LDG','Landing'}
            TiD = C_Tdesld * Tmaxcl;

        otherwise
            TiD = -999999999;
    end
end