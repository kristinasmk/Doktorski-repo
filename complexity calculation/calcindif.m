function [calcindi] =calcindif (ACAcell,tstart,raster)

dt=[tstart,tstart+20*60]; %start and end time of cell timeframe

%filter lines within desired time
 if ~isempty(ACAcell)
    c=ACAcell(:,10)>=dt(1) & ACAcell(:,10)<dt(2);

    %ACAcell logged data goes as follows: [ACid,Lat,Lon,TAS,ROCD,FL,CRS,GS,Flight mode, time, cell coords,cloud_interaction]
    ACAcell=ACAcell(c,:);
 end
 
 if ~isempty(ACAcell)
    n=unique(ACAcell(:,1));
    FT_AC=[];
    for i=1:size(n,1)
       U=ACAcell(ACAcell(:,1)==n(i),:);
       if size(U,1)>1
           U=[size(U,1)*raster/60,U(1,7),mean(U(:,8)),U(1,9),max(U(:,13))]; %divided by 60 to have time in minutes
       else
           U=[raster/60,U(1,7),U(1,8),U(1,9),U(1,13)]; %nije 60 ako ostavim zapis svaku sekunde
       end
       FT_AC=[FT_AC;U];
    end
    %in New variable is ac data in cell logged as fallows [time,CRS,GS,Flight mode,cloud_interaction]
    %Flight modes 1-climb, 2-descent, 0-cruise
    
        dims=size(FT_AC);
        FT=sum(FT_AC(:,1)); %total fligh hours in cell


        %iHOURS OF INTERACTION  [TX]
        TXn=zeros(dims(1),1);
        for nAC=1:dims(1)
            TXn(nAC)=FT_AC(nAC,1)*(FT-FT_AC(nAC,1));
        end
        TX=sum(TXn);  %HOURS OF INsuma vremena interakcije (TERACTION)


        %izra?un HOURS OF VERTICAL INTERACTION  [VDIF ili TXV]
        FT_AC_mod=zeros(3,1);
        for M=0:2
            FT_AC_M=FT_AC(FT_AC(:,4)==M);  %popis AC-a u modu M
            FT_AC_nM=FT_AC(FT_AC(:,4)~=M); %popis AC-a NE u modu M
            FT_AC_Mn=zeros(size(FT_AC_M,1),1);
            for Mn=1:numel(FT_AC_M)
                FT_AC_Mn(Mn)=FT_AC_M(Mn)*(sum(FT_AC_nM));
            end
            FT_AC_mod(M+1)=sum(FT_AC_Mn);    
        end
        TXV=sum(FT_AC_mod);


        %izra?un HOURS OF HORIZONTAL INTERACTION  [HDIF ili TXH]
        TXH_AC=zeros(dims(1),1); %kreiranje prazne tablice interakcija za svaki AC
        for Hdg=1:dims(1)                   %punjenje tablice
            HDGm=NavAngleToMathAngle (FT_AC(:,2));                                  %odre?ivanje koji su zrakoplovi u interakciji
            ACh=NavAngleToMathAngle(FT_AC(Hdg,2));
            HDGd=HDGm>=ACh+20*0.0174532925199433 | ACh-20*0.0174532925199433>=HDGm;% na nacin da im je delta hdg veci ili jednak od 20
            HDG_N=FT_AC(HDGd,1);                % izdvajanje navedenih redova
            TXH_AC(Hdg)=FT_AC(Hdg,1)*sum(HDG_N); %vrijeme interakcije za svaki ac
        end
        TXH=sum(TXH_AC);


        %izra?un HOURS OF SPEED INTERACTION [SDIF ili TXS]
        TXS_AC=zeros(dims(1),1); %kreiranje prazne tablice interakcija za svaki AC
        for Spd=1:dims(1)                   %punjenje tablice
            SPDd=abs(FT_AC(:,3)-FT_AC(Spd,3));  %odredivanje koji su zrakoplovi u interakciji 
            SPDd=SPDd*1.943844>35;              % na nacin da im je delta speed veci od 35 kt (multiplied by 1.9 to change from m/s to kt)
            SPD_N=FT_AC(SPDd,1);                % izdvajanje navedenih redova
            TXS_AC(Spd)=FT_AC(Spd,1)*sum(SPD_N); %vrijeme interakcije za svaki ac
        end
        TXS=sum(TXS_AC);

        % HOURS OF CLOUD INTERACTIONS [TXC] 
        %implemented
        if max(FT_AC(:,5))>0
            TXC_AC=FT_AC(logical(FT_AC(:,5)),1).*FT_AC(logical(FT_AC(:,5)),1);
            TXC=sum(TXC_AC);
        else
            TXC=0;
        end

    calcindi=[FT TX TXV TXH TXS TXC];
else
    calcindi=[];%[0 0 0 0 0 0];
    
end