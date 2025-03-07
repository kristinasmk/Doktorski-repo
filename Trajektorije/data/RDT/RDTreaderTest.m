clear
constants
dT=5;

files=dir('*.nc');

%karta svih zna�ajnih oblaka po levelu (level obja�njen u pdfu)
mapcloud=ncread(files(2).name,'MapCellCatType');

%koordinate svih pixela mape u metrima
Lon=ncread(files(2).name,'nx');
Lat=ncread(files(2).name,'ny');

%koordinate u stupnjevima (nije dobro)
%lat=km2deg(Lat/1000);
%lon=km2deg(Lon/1000);
gdal_xgeo=ncreadatt(files(2).name,'/','gdal_xgeo_up_left');
gdal_ygeo=ncreadatt(files(2).name,'/','gdal_ygeo_up_left');
pix_size=3000.403357; %[m]


xc = gdal_xgeo + (Lon+0.5) * pix_size; %[m],, i=0; xc-1
yc = gdal_ygeo - (Lat+0.5) * pix_size; %[m],, j=0; yc-1


%odrezak karte - Hrvatska s okolicom
slon=1653;
slat=290;
lonm=lon(slon:end);
latm=lat(1:slat);
map=mapcloud(slon:end,1:slat);

%Smanjivanje dimenzija karte
R=reshape(map,2,round(length(lonm)/2),2,round(length(latm)/2));
S=round(sum(sum(R,1),3)*0.25);
mapsmall=reshape(S,round(length(lonm)/2),round(length(latm)/2));

%Top and Bot of cloud
alt=ncread(files(2).name,'CTPressure');
alt=[alt(1,:)',alt(2,:)'];

%Contours Lon and Lat
LonCont=ncread(files(2).name,'LonContour');
LatCont=ncread(files(2).name,'LatContour');

%atmospthere
[T, p, rho, a] = AtmosphereAtHp((100:1000:50000)*0.3048, dT, const);
p=p';
n=1;

Clouddata=cell(size(LatCont,3),3);
%Separating each cloud data
for i=1:size(LatCont,3)
    Bot=alt(i,2);
    Top=alt(i,1);
    
    %top and bottom FL of cloud
    [~,idxB]=min(abs(p-Bot));
    [~,idxT]=min(abs(p-Top));
    
    CloudFL(1)=idxB;
    CloudFL(2)=idxT;
    
    Clouddata(i,1)={CloudFL};
    
    %Cloud contours
    Latcb=LatCont(:,1,i);
    Latcb=Latcb(~isnan(Latcb));
    Loncb=LonCont(:,1,i);
    Loncb=Loncb(~isnan(Loncb));
    
    if max(Latcb)> lat(1)
       Latcb(Latcb>lat(1))=lat(1); 
    end
    
    if max(Loncb)>lon(end)
       Loncb(Loncb>lon(end))= lon(end); 
    end
    
    Latct=LatCont(:,2,i);
    Latct=Latct(~isnan(Latct));
    Lonct=LonCont(:,2,i);
    Lonct=Lonct(~isnan(Lonct));
    
    
    Clouddata(i,2)={[[Latcb,Loncb];[Latcb(1),Loncb(1)]]};
    Clouddata(i,3)={[[Latct,Lonct];[Latcb(1),Loncb(1)]]};
    
    %separating clouds with vertical growth
    if idxB~=idxT
        CloudVert(n,1)={CloudFL};
        CloudVert(n,2)={[[Latcb,Loncb];[Latcb(1),Loncb(1)]]};
        CloudVert(n,3)={[[Latct,Lonct];[Latcb(1),Loncb(1)]]};
        n=n+1;
    end
    
end

% expanding 2d map to 3d map using extracted cloud data
% map3dall=zeros([size(map),length(alt)]);
map3dall=zeros([size(mapcloud),length(alt)]);
map3d=map3dall;
Cloudalt=cell2mat(Clouddata(:,1));

clouds=zeros(size(mapcloud));

for c=1:size(Clouddata,1)
   Cloud=Clouddata{c,2};
   clon=zeros(size(Cloud,1),1);
   clat=clon;
   for n=1:size(Cloud,1)
       clon(n)=posfind(Cloud(n,2),lon);
       clat(n)=posfind(Cloud(n,1),lat); 
   end
   mask=poly2mask(clat,clon,size(mapcloud,1),size(mapcloud,2));
   clouds=clouds+mask;
end

% 
% %starting point of matrix
% lonstart=lon(slon); %all cloud points are right (east) of starting point
% latstart=lat(slat); %all cloud points are above (north) of starting point
% 
% for al=1:size(map3d,3)
%     %find clouds that are at selected level
%     if max(al>=Cloudalt(:,1) & al<=Cloudalt(:,2))>0 
%         CloudsLvl=Clouddata((al>=Cloudalt(:,1) & al<=Cloudalt(:,2)),:);
%         
%         %check alt of all clouds
%         for n=1:size(CloudsLvl,1)
%             Cloud=CloudsLvl{n,2};
% %             clon=double(round((Cloud(:,2)-lonstart)/0.0270)); %0.0270 is step of grid
% %             clat=double(round((Cloud(:,1)-latstart)/0.0270));
% 
%              clon=double(round(Cloud(:,2)/0.0270)); %0.0270 is step of grid
%              clat=double(round(Cloud(:,1)/0.0270));
% 
%             mask=flip(poly2mask(clon,clat,size(mapcloud,1),size(mapcloud,2)));
%             map3dall(:,:,al)= map3dall(:,:,al)+mask;
%         end
%         
%         a=map3dall(:,:,al)>0;
%         b=mapcloud>0;
%         
%         if max(max(a&b))>0
%             map3d(a&b)=al;
%         end
%         
%     end
%     
% end

figure
hold on
for c=1:size(Clouddata,1)
    Cloud2=Clouddata{c,2};
    plot(Cloud2(:,2),Cloud2(:,1))
    
end















































