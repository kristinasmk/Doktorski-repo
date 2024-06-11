function [WPT] = CloudOutVector (ACstate,Cloud)
%this function simulates weather radar cone to find best shortest path out
%of cloud
% %airborne weather radar cone

Heading = MathtoNavAngle (ACstate(5));
ACpos=[ACstate(1) ACstate(2)];

%range of radar
Range=nm2deg(100); %radar range 80 NM
cover=0:2:60;
% span of radar cone left and right from heading
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
Radarpoints=zeros(size(cone,2),2);
Distance=zeros(size(cone,2),1);

%searching for shortest distance from aircraft to edge of cloud
for i=1:size(cone,2)
    % This part of code will create radar lines to check cloud crossings
    Radarpoint=reckon(ACpos(2),ACpos(1),Range,cone(i));
    Radarpoints(i,:)=Radarpoint;
    Radarline(1,:)=[ACpos(2) Radarpoint(1)];
    Radarline(2,:)=[ACpos(1) Radarpoint(2)];
    
    %polyxpoly is looking for coordinates where radar lines cross clouds
    [cx,cy]=polyxpoly(Radarline(1,:),Radarline(2,:),Cloud(:,1),Cloud(:,2));
    if ~isempty(cx)
        if size(cx,1)>1
            dist=zeros(size(cx,1),1);
            for n=1:size(cx,1)
            dist(n)=sqrt((ACpos(1)-cy(n))^2+(ACpos(2)-cx(n))^2);
            end
            Distance(i)=min(dist);
        else
            Distance(i)=sqrt((ACpos(1)-cy)^2+(ACpos(2)-cx)^2);
        end
    else
    Distance(i)=4;
    end
end

%creating waypoint at edge of cloud
Dpos=Distance==min(Distance);

%if AC is close to cloud border and there is no significant difference
%between going out on shortest path or going strainght plane will continue
%straight
if abs(Distance(Dpos)-Distance(31))<0.1 && Distance(31)<0.3331
    Dpos=31;
end
    

if min(Distance)>0.015
    Spath(1,:)=[ACpos(2) Radarpoints(Dpos,1)];
    Spath(2,:)=[ACpos(1) Radarpoints(Dpos,2)];
    [cx,cy]=polyxpoly(Spath(1,:),Spath(2,:),Cloud(:,1),Cloud(:,2));

for s=1:length(cx)
    D(s)=sqrt((ACpos(2)-cx(s))^2+(ACpos(1)-cy(s))^2);
end
  D=D==min(D);
  
if max(sum(D))>1
    D=find(D==1);
    D=D(1);
end
  
% shifting waypoint for 9nm further down desired path to avoind borders for astar   
[dist, az]=distance(ACpos(2),ACpos(1),cx(D),cy(D));
[WPT(2), WPT(1)]=reckon(ACpos(2),ACpos(1),dist+0.10,az);

else
    WPT=[];
end

end

