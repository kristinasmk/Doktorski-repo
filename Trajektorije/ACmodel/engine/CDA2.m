function [wptlist] = CDA2 (waypoints, ACstate,WPTi,dT,const,ACmode,GP,apfdata,opsdata,ACcontrol,Wind)
%this function will check if AC is landing at next WPT and calculate TOD
%for descent
t=1;
% ACstate(3)=max([waypoints(:).z]);
% ACmode.CL='C';
% ACmode.ACC='C';
% ACmode.ConfigMode='CL';
% ACstate(4)=opsdata.Vdesref;
% ACstate(6)=ACstate(6)*0.9;
startALT=ACstate(3);
while ACstate(3)>waypoints(end).z+150
    
% 1. Determine conditions at current alt for current meteo
    [AtmHp.T, AtmHp.p, AtmHp.rho, AtmHp.a] = AtmosphereAtHp(ACstate(3), dT, const);
    
    % 2. Determine altitude
    % [geopotential_alt]=GeodeticToGeopotential(const, geodetic_alt); 
    if ACstate(3)>11000 
        ACmode.tropo=true;
    else
        ACmode.tropo=false;
    end
    % 3. Determine all speeds (TAS to CAS to Mach)
    CAScurrent=TAStoCAS(AtmHp.p, AtmHp.rho, ACstate(4)); %ACstate(4) - TAS
    MACHcurrent=TAStoMach(AtmHp.T, ACstate(4));
    TransAlt=CrossAlt(CAScurrent, MACHcurrent, dT, const);
    
    if ACstate(3)>TransAlt  %switch for constant CAS or Mach in respect to Transition (crossover) altitude
        ACmode.SpeedMode='M';
    else
        ACmode.SpeedMode='C';
    end
    
    % 4. Determine phase of flight: (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
    ACmode.CL=CLModeSet(ACstate(3),waypoints(end).z,ACmode.CL,GP.Htol); %setting AC regime
    ACmode.ConfigMode=ConfigModeSet(GP,opsdata,ACstate(3),CAScurrent,ACmode.CL); %Setting config mode
    
    % 5. Determine acceleration mode: (A)ccelerating, (C)onstant, (D)ecelerating, and desired TAS
    desiredTAS = DesiredTASf (GP,apfdata,opsdata,ACmode.CL,ACstate(6),AtmHp,ACmode.ConfigMode,ACstate(3),TransAlt,const);
    ACmode.ACC = ACCModeSet (ACstate(4),desiredTAS,ACmode.ACC,GP.Vtol);
    
    % 6. Determine energy share factor
    esf=energysf(MACHcurrent, AtmHp.T, dT, ACmode.ACC, ACmode.CL, ACmode.SpeedMode, ACmode.tropo, const);
    
    % 7. Determine ACcontrol inputs
    %   7.a. Lift and Drag
        CL = LiftCoefficient(ACstate(6), AtmHp.rho, opsdata.wingsurf, ACstate(4), ACcontrol(2),const);
        ACcontrol(4)= ACDragCoef (opsdata, ACmode.ConfigMode, CL);
    %   7.b. Thrust
        ACcontrol(1)= ThrustSet (GP, opsdata, ACstate, ACcontrol, AtmHp, ACmode, desiredTAS, const);
    %   7.c. Pitch
        ACcontrol(3)=PitchSet (opsdata, GP, ACstate, ACcontrol, waypoints(end).z, esf, AtmHp, const);
    %   7.d. Bank
        ACcontrol(2)=BankSet (GP, ACstate, ACcontrol, waypoints, WPTi,ACmode.ConfigMode, Wind, const);
    
    % 8. Fuel consumption
    FF = FuelConsumption(ACstate(4), ACcontrol(1),  ACstate(3), ...
        opsdata.Cf1,  opsdata.Cf2,  opsdata.Cf3,  opsdata.Cf4, ...
        opsdata.Cfcr, opsdata.engtype, ACmode.CL);

    % calculate next ACstate
    ACSm1=ACstate;
    ACstate = ACStateUpdate(ACstate, ACcontrol, Wind,  opsdata.wingsurf,  AtmHp.rho,  FF, CL, const);
    
    D(t)=distance(ACstate(2),ACstate(1),ACSm1(2),ACSm1(1));
    t=t+1;
end

%remove last CDA
[~,cdapos]=max(strcmp([waypoints.name],'CDA'));

waypoints=[waypoints(1:cdapos-1),waypoints(cdapos+1:end)];
    
    Ds=sum(D);
    p1=size(waypoints,2);
    leg=distance(waypoints(p1).y,waypoints(p1).x,waypoints(p1-1).y,waypoints(p1-1).x);
    maxleg=0;
    for m=2:p1
        maxleg=maxleg+distance(waypoints(m).y,waypoints(m).x,waypoints(m-1).y,waypoints(m-1).x);
    end
    
    if maxleg>Ds %if ac has passed its CDA mark before start of simulation
        while Ds>leg
           Ds=Ds-leg;
           p1=p1-1;
           leg=distance(waypoints(p1).y,waypoints(p1).x,waypoints(p1-1).y,waypoints(p1-1).x);
        end

        az=azimuth(waypoints(p1-1).y,waypoints(p1-1).x,waypoints(p1).y,waypoints(p1).x);
        az=az-180;
            if az<0
             az=az+360;
            end
            
    else
        waypoints(1).name='CDA';
    end

%second iteration of CDA if calculated CDA is at route segmet than is on lower altitide than max route alt 
    if waypoints(p1-1).z < max([waypoints(:).z])
    
    ACstate(3)=waypoints(p1-1).z;
    
    while ACstate(3)>waypoints(end).z+150

    % 1. Determine conditions at current alt for current meteo
        [AtmHp.T, AtmHp.p, AtmHp.rho, AtmHp.a] = AtmosphereAtHp(ACstate(3), dT, const);

        % 2. Determine altitude
        % [geopotential_alt]=GeodeticToGeopotential(const, geodetic_alt); 
        if ACstate(3)>11000 
            ACmode.tropo=true;
        else
            ACmode.tropo=false;
        end
        % 3. Determine all speeds (TAS to CAS to Mach)
        CAScurrent=TAStoCAS(AtmHp.p, AtmHp.rho, ACstate(4)); %ACstate(4) - TAS
        MACHcurrent=TAStoMach(AtmHp.T, ACstate(4));
        TransAlt=CrossAlt(CAScurrent, MACHcurrent, dT, const);

        if ACstate(3)>TransAlt  %switch for constant CAS or Mach in respect to Transition (crossover) altitude
            ACmode.SpeedMode='M';
        else
            ACmode.SpeedMode='C';
        end

        % 4. Determine phase of flight: (T)ake-(O)ff = TO, (I)nitial (C)limb, (CL)ean, (APP)roach, (L)an(D)in(G)
        ACmode.CL=CLModeSet(ACstate(3),waypoints(end).z,ACmode.CL,GP.Htol); %setting AC regime
        ACmode.ConfigMode=ConfigModeSet(GP,opsdata,ACstate(3),CAScurrent,ACmode.CL); %Setting config mode

        % 5. Determine acceleration mode: (A)ccelerating, (C)onstant, (D)ecelerating, and desired TAS
        desiredTAS = DesiredTASf (GP,apfdata,opsdata,ACmode.CL,ACstate(6),AtmHp,ACmode.ConfigMode,ACstate(3),TransAlt,const);
        ACmode.ACC = ACCModeSet (ACstate(4),desiredTAS,ACmode.ACC,GP.Vtol);

        % 6. Determine energy share factor
        esf=energysf(MACHcurrent, AtmHp.T, dT, ACmode.ACC, ACmode.CL, ACmode.SpeedMode, ACmode.tropo, const);

        % 7. Determine ACcontrol inputs
        %   7.a. Lift and Drag
            CL = LiftCoefficient(ACstate(6), AtmHp.rho, opsdata.wingsurf, ACstate(4), ACcontrol(2),const);
            ACcontrol(4)= ACDragCoef (opsdata, ACmode.ConfigMode, CL);
        %   7.b. Thrust
            ACcontrol(1)= ThrustSet (GP, opsdata, ACstate, ACcontrol, AtmHp, ACmode, desiredTAS, const);
        %   7.c. Pitch
            ACcontrol(3)=PitchSet (opsdata, GP, ACstate, ACcontrol, waypoints(end).z, esf, AtmHp, const);
        %   7.d. Bank
        
        if WPTi>size(waypoints,2)
            WPTi=WPTi-1;
        end
            ACcontrol(2)=BankSet (GP, ACstate, ACcontrol, waypoints, WPTi,ACmode.ConfigMode, Wind, const);

        % 8. Fuel consumption
        FF = FuelConsumption(ACstate(4), ACcontrol(1),  ACstate(3), ...
            opsdata.Cf1,  opsdata.Cf2,  opsdata.Cf3,  opsdata.Cf4, ...
            opsdata.Cfcr, opsdata.engtype, ACmode.CL);

        % calculate next ACstate
        ACSm1=ACstate;
        ACstate = ACStateUpdate(ACstate, ACcontrol, Wind,  opsdata.wingsurf,  AtmHp.rho,  FF, CL, const);

        D(t)=distance(ACstate(2),ACstate(1),ACSm1(2),ACSm1(1));
        t=t+1;
    end

        Ds=sum(D);
        p1=size(waypoints,2);
        leg=distance(waypoints(p1).y,waypoints(p1).x,waypoints(p1-1).y,waypoints(p1-1).x);
        
    for m=2:p1
        maxleg=maxleg+distance(waypoints(m).y,waypoints(m).x,waypoints(m-1).y,waypoints(m-1).x);
    end
    
        if maxleg>Ds

            while Ds>leg
               Ds=Ds-leg;
               p1=p1-1;
               if p1==1
                   p1=2;
               end
               leg=distance(waypoints(p1).y,waypoints(p1).x,waypoints(p1-1).y,waypoints(p1-1).x);
            end

            az=azimuth(waypoints(p1-1).y,waypoints(p1-1).x,waypoints(p1).y,waypoints(p1).x);
            az=az-180;
                if az<0
                 az=az+360;
                end
        else
            waypoints(1).name='CDA';
        end
    end
    
    if ~strcmp(waypoints(1).name,'CDA')  
        [latout,lonout]=reckon(waypoints(p1).y,waypoints(p1).x,Ds,az);
        if size(waypoints,2)<WPTi
            WPTi=size(waypoints,2)
        end
        
        A=waypoints(1:p1-1);
        wpta=waypoints(WPTi).z;
        if wpta<startALT
            for a=WPTi-1:size(A,2)
               A(a).z=startALT; 
            end
        end
        
        B.y=latout;
        B.x=lonout;
        %if AC is already in descent
        if waypoints(p1-1).z>startALT
            B.z=startALT;
        else
            B.z=waypoints(p1-1).z;
        end
        
        B.flyover=0;
        B.hist=1;
        B.name={'CDA'};
        C=waypoints(p1:end);

        wptlist=[A,B,C];
        [wptlist(p1+1:end).z]=deal(0); %set all alts to 0 after CDA mark
    else
        wptlist=waypoints;
    end
end