clear
load clouds2.mat
ACstate=[18 45.2 8000 250 180 20000];
%airborne weather radar cone
Heading=ACstate(5);
ACpos=[ACstate(1) ACstate(2) ACstate(3)];
Range=nm2deg(80); %radar range 80 NM
cover=0:2:60;

hdgL=Heading-cover;
if sum(hdgL<0)>0
    hdgL(hdgL<0)=hdgL(hdgL<0)+360;
end
hdgL=flip(hdgL,2);

hdgR=Heading+cover;
if sum(hdgR>360)>0
    hdgR(hdgR>360)=hdgR(hdgR>360)-360;
end

cone=[hdgL,hdgR(2:end)];

for i=1:size(cone,2)
    Radarpoint=reckon(ACpos(2),ACpos(1),Range,cone(i));
    Radarpoints(i,:)=Radarpoint;
end

% Radarcone(1,:)=[ACpos(2) Radarpoints(1,1)];
% Radarcone(2,:)=[ACpos(1) Radarpoints(1,2)];


for r=1:size(cone,2)
    Radarline(1,:)=[ACpos(2) Radarpoints(r,1)];
    Radarline(2,:)=[ACpos(1) Radarpoints(r,2)];
    
%     Radarcone=[Radarcone Radarline];
    
    [cx,cy]=polyxpoly(Radarline(1,:),Radarline(2,:),Cloud46(:,1),Cloud46(:,2));
    Cross(r,1)={cx};
    Cross(r,2)={cy};
end

Radarline(1,:)=[ACpos(2) Radarpoints(30,1)];
Radarline(2,:)=[ACpos(1) Radarpoints(30,2)];
[cx1,cy1]=polyxpoly(Radarline(1,:),Radarline(2,:),Cloud46(:,1),Cloud46(:,2));

Radarline(1,:)=[ACpos(2) Radarpoints(32,1)];
Radarline(2,:)=[ACpos(1) Radarpoints(32,2)];
[cx2,cy2]=polyxpoly(Radarline(1,:),Radarline(2,:),Cloud46(:,1),Cloud46(:,2));



if ~isempty(cx1) == 1 || ~isempty(cx2) == 1
    
    n=1;
    cl=31;
    cr=31;
    
    while n<31
        RadarlineL(1,:)=[ACpos(2) Radarpoints(cl,1)];
        RadarlineL(2,:)=[ACpos(1) Radarpoints(cl,2)];

        [cxl,cyl]=polyxpoly(RadarlineL(1,:),RadarlineL(2,:),Cloud46(:,1),Cloud46(:,2));

        if isempty(cx1)== 1
            Dev=Radarpoints(cl,:);
            n=31;
        end

        RadarlineR(1,:)=[ACpos(2) Radarpoints(cr,1)];
        RadarlineR(2,:)=[ACpos(1) Radarpoints(cr,2)];

        [cxr,cyr]=polyxpoly(RadarlineR(1,:),RadarlineR(2,:),Cloud46(:,1),Cloud46(:,2));
        
        if isempty(cxr)== 1
            Dev=Radarpoints(cr,:);
            n=31;
        end
        
        n=n+1;
        cl=cl-1;
        cr=cr+1;
    end
    
end