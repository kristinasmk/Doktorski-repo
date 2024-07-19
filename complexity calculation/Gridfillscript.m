clear
addpath(genpath(pwd))
%grid filling

%create PRU grid
[grids,polygon,dims] = gridcreate (10,45,18,50,20,100,450);

%load traffic
load Tps.mat
load Cloudmasks2.mat

%fill PRU grid
TP=cell(size(TPs,2),4);
for p=1:4 %for every horizontal shift in PRU grid
    for a=221%1:size(TPs,2) %for every aircraft in TPs
        ACweather=cell(size(TPs(a).TPsample,1)/5,5);
        y=1;
        x=1;
        for t=1:size(TPs(a).TPsample,1) %for every tp of a specific aircraft

        A=TPs(a).TPsample{t,1};
        ACname=TPs(a).info.flight_id;
        %locating position of aircraft within PRU grid
        [ACgrid] = gridfillAC (A,polygon,p,ACname);
        %logg weather interactions for each aircraft
        ACgrid = cloudcheck_v2 (ACgrid,AllClouds,dims,x,p);
        
        %sort aircraft according to weather scenario
        %x=TPs(a).TPsample{t,3};
        ACweather(x,y)={ACgrid};
        y=y+1;
            if y>5
                y=1;
                x=x+1;
            end
        end
        %logged data goes as follows: [Lat,Lon,TAS,ROCD,FL,CRS,GS]
        TP(a,p)={ACweather};
    end
end

save ('TPgrid2_NAVSIM', 'TP')
