clear
constants
dT=5;

files=dir('*.nc');

%karta svih znaèajnih oblaka po levelu (level objašnjen u pdfu)
mapcloud=ncread(files(1).name,'MapCellCatType');

%koordinate svih pixela mape u metrima
Lon=ncread(files(1).name,'nx');
Lat=ncread(files(1).name,'ny');

%koordinate u stupnjevima
lat=km2deg(Lat/1000);
lon=km2deg(Lon/1000);

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
alt=ncread(files(1).name,'CTPressure');
alt=[alt(1,:)',alt(2,:)'];

%Contours Lon and Lat
LonCont=ncread(files(1).name,'LonContour');
LatCont=ncread(files(1).name,'LatContour');

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

%starting point of matrix
lonstart=lon(slon); %all cloud points are right (east) of starting point
latstart=lat(slat); %all cloud points are above (north) of starting point

for al=1:size(map3d,3)
    %find clouds that are at selected level
    if max(al>=Cloudalt(:,1) & al<=Cloudalt(:,2))>0 
        CloudsLvl=Clouddata((al>=Cloudalt(:,1) & al<=Cloudalt(:,2)),:);
        
        %check alt of all clouds
        for n=1:size(CloudsLvl,1)
            Cloud=CloudsLvl{n,2};
%             clon=double(round((Cloud(:,2)-lonstart)/0.0270)); %0.0270 is step of grid
%             clat=double(round((Cloud(:,1)-latstart)/0.0270));

             clon=double(round(Cloud(:,2)/0.0270)); %0.0270 is step of grid
             clat=double(round(Cloud(:,1)/0.0270));

            mask=flip(poly2mask(clon,clat,size(mapcloud,1),size(mapcloud,2)));
            map3dall(:,:,al)= map3dall(:,:,al)+mask;
        end
        
        a=map3dall(:,:,al)>0;
        b=mapcloud>0;
        
        if max(max(a&b))>0
            map3d(a&b)=al;
        end
        
    end
    
end

















































