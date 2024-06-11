clear
constants
dT=0;

files=dir('*.nc');
Clouddata = cell(size(files,1),3);

for f=1:size(files,1)
    
%Top and Bot of cloud
alt=ncread(files(f).name,'CTPressure');
alt=[alt(1,:)',alt(2,:)'];

%Contours Lon and Lat
LonCont=ncread(files(f).name,'LonContour');
LatCont=ncread(files(f).name,'LatContour');
CloudID=ncread(files(f).name,'NumIdCell');
CloudBirth=ncread(files(f).name,'NumIdBirth');
Duration=ncread(files(f).name,'Duration');
ConvType=ncread(files(f).name,'ConvType');
SeverityType=ncread(files(f).name,'SeverityType');
SeverityIntensity=ncread(files(f).name,'SeverityIntensity');



%atmospthere
[~, p, ~, ~] = AtmosphereAtHp((100:1000:50000)*0.3048, dT, const);
p=p';
n=1;

    Clouds=cell(size(LatCont,3),9);
    %Separating each cloud data
    for i=1:size(LatCont,3)
        Bot=alt(i,2);
        Top=alt(i,1);

        %top and bottom FL of cloud
        [~,idxB]=min(abs(p-Bot));
        [~,idxT]=min(abs(p-Top));

        CloudFL(1)=idxB;
        CloudFL(2)=idxT;

        Clouds(i,1)={CloudFL};

        %Cloud contours
        Latcb=LatCont(:,1,i);
        Latcb=Latcb(~isnan(Latcb));
        Loncb=LonCont(:,1,i);
        Loncb=Loncb(~isnan(Loncb));

        Latct=LatCont(:,2,i);
        Latct=Latct(~isnan(Latct));
        Lonct=LonCont(:,2,i);
        Lonct=Lonct(~isnan(Lonct));

        %logging cloud data
        Clouds(i,2)={[[Latcb,Loncb];[Latcb(1),Loncb(1)]]};
        Clouds(i,3)={[[Latct,Lonct];[Latcb(1),Loncb(1)]]};
        Clouds(i,4)={CloudID(i)};
        Clouds(i,5)={CloudBirth(i)};
        Clouds(i,6)={Duration(i)};
        Clouds(i,7)={ConvType(i)};
        Clouds(i,8)={SeverityType(i)};
        Clouds(i,9)={SeverityIntensity(i)};
        
    end
    
    %logging cloud data per nc file
    Clouddata(f,3)={Clouds};
    
    %creating time stamp in HHMMSS (first column) and SSSSS (second col) format
    t=files(f).name;
    t=t(end-9:end-4);
    Clouddata(f,1)={t};
    Clouddata(f,2)={time_conv(t)};
    
    
end

save ('Clouddata0511','Clouddata')