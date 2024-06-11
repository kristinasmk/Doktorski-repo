
%Peto poglavlje BADA manuala Global Paramethers

GP.Almax = 2; %maximum longitudinal acceleration for civil flights: ft/s2
GP.Anmax = 5; %maximum normal acceleration for civil flights: ft/s2

GP.phi_nom_to = 15; %Nominal bank angles for civil flight during TO and LD: deg
GP.phi_nom_oth = 30; %Nominal bank angles for civil flight during all other phases: deg
GP.phi_nom_mil=50; %Nominal bank angles for military flight
GP.phi_max_to = 25; %Maximum bank angles for civil flight during TO and LD: deg
GP.phi_max_hold = 35; %Maximum bank angles for civil flight during HOLD: deg
GP.phi_max_oth = 45; %Maximum bank angles for civil flight during all other phases: deg
GP.phi_max_mil=70; %Maximum bank angles for military flight

GP.Cdes_exp = 1.6; %Expedited descent factor

GP.Ctto= 1.2; %Maximum takeoff  thrust coefficient
GP.Ctcr = 0.95; %Maximum cruise  thrust coefficient

GP.Hmax_to = 400; %Maximum altitude threshold for take-off: ft
GP.Hmax_ic = 2000; %Maximum altitude threshold for initial climb: ft
GP.Hmax_ap = 8000; %Maximum altitude threshold for approach: ft
GP.Hmax_ld = 3000; %Maximum altitude threshold for landing: ft

GP.Cvmin_to = 1.2; %Minimum speed coefficient for take-off
GP.Cvmin = 1.3; %Minimum speed coefficient (all other phases)

GP.Vdcl1 = 5; %Climb speed increment below 1500 ft (jet): KCAS
GP.Vdcl2 = 10; %Climb speed increment below 3000 ft (jet): KCAS
GP.Vdcl3 = 30; %Climb speed increment below 4000 ft (jet): KCAS
GP.Vdcl4 = 60; %Climb speed increment below 5000 ft (jet): KCAS
GP.Vdcl5 = 80; %Climb speed increment below 6000 ft (jet): KCAS
GP.Vdcl6 = 20; %Climb speed increment below 500 ft (turbo/piston): KCAS
GP.Vdcl7 = 30; %Climb speed increment below 1000 ft (turbo/piston): KCAS
GP.Vdcl8 = 35; %Climb speed increment below 1500 ft (turbo/piston): KCAS
GP.Vddes1 = 5; %Descent speed increment below 1000 ft (jet/turboprop): KCAS
GP.Vddes2 = 10; %Descent speed increment below 1500 ft (jet/turboprop): KCAS
GP.Vddes3 = 20; %Descent speed increment below 2000 ft (jet/turboprop): KCAS
GP.Vddes4 = 50; %Descent speed increment below 3000 ft (jet/turboprop): KCAS
GP.Vddes5 = 5; %Descent speed increment below 500 ft (piston): KCAS
GP.Vddes6 = 10; %Descent speed increment below 1000 ft (piston): KCAS
GP.Vddes7 = 20; %Descent speed increment below 1500 ft (piston): KCAS

GP.Vhold1 = 230; %Holding speed below FL140: KCAS
GP.Vhold2 = 240; %Holding speed between FL140 and FL200: KCAS
GP.Vhold3 = 265; %Holding speed between FL200 and FL340: KCAS
GP.Vhold4 = 0.83; %Holding speed above FL340: Mach

GP.Vbtrack = 35; %Runway backtrack speed: KCAS
GP.Vtaxi = 15; %Taxi speed: KCAS
GP.Vapron = 10; %Apron speed: KCAS
GP.Vgate = 5; %Gate speed: KCAS

GP.Cred_tprop = 0.25; %Maximum reduction in power for turboprops
GP.Cred_pis = 0.0; %Maximum reduction in power for pistons
GP.Cred_jet = 0.15; %Maximum reduction in power for jets

% u buduænosti bi moglo iæi u opsdata
GP.Vtol = 1; %Tolerated speed difference from nominal
GP.Htol = 15; %Tolerated altitude difference from nominal