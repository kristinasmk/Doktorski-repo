function [NewFP,NewWPT] = AstarRoute (lon1, lon2, lat1, lat2, Clouds, ACpos, WP, NeighboorsTable)


lons=round((lon2-lon1)*60);
lats=round((lat2-lat1)*60);


%1 represent an object that the path cannot penetrate, zero is a free path
MAP=int8(zeros(lats,lons));

for i=1:size(Clouds,2)
    c=Clouds{(i)};
    cy=round((c(:,1)-lat1)*60);
    cx=round((c(:,2)-lon1)*60);
    mask=poly2mask(cx,cy,lats,lons);
    MAP=MAP+int8(mask);
    
    %ovaj dio koda provjerava je li waypoint u oblaku i ako je prebacuje ga
    %po kursu ispred oblaka
    if inpolygon(WP(2),WP(1),c(:,2),c(:,1)) == 1
     [WPx,WPy]=polyxpoly([ACpos(2) WP(2)],[ACpos(1) WP(1)],c(:,2),c(:,1));
      if WPx>WP(2)
          WPx=WPx+0.1; %0.1 stupanj se dodaje jer polyxpoly stavlja toèku na sam rub
      elseif WPx<WP(2)
          WPx=WPx-0.1;
      end
      
      if WPy>WP(1)
          WPy=WPy+0.1;
      elseif WPy<WP(1)
          WPy=WPy-0.1;
      end
      WP(2)=WPx;
      WP(1)=WPy;
      NewWPT=[WPy,WPx]; 
    end
end
MAP=int8(MAP>0);


%Start Positions
StartY=round((ACpos(1)-lat1)*60);
StartX=round((ACpos(2)-lon1)*60);

%Generating goal nodes, which is represented by a matrix. In 2sided version
%only one goal node can be specified

GoalY=round((WP(1)-lat1)*60);
GoalX=round((WP(2)-lon1)*60);


%CONNECTING DISTANCEA
D=floor((sqrt((StartX-GoalX)^2+(StartY-GoalY)^2)));
Connecting_Distance=D-2;
if Connecting_Distance<1
    Connecting_Distance=1;
    
elseif Connecting_Distance>20
    Connecting_Distance=20;
end


% A MORE EFFICIENT SOLVER

Neighboors=NeighboorsTable{Connecting_Distance};


%THE MOST EFFICIENT SOLVER; TWO SIDED SOVLER (ALSO 
OptimalPath=ASTARPATH2SIDED(StartX,StartY,MAP,GoalX,GoalY,Connecting_Distance,Neighboors);

%cleaning a bit - finding points that repeat and removing them (two
%possible paths)
[~,idxu,idxc] = unique(OptimalPath,'rows');
[count, ~, idxcount] = histcounts(idxc,numel(idxu));
idxkeep = count(idxcount)>1;
b=OptimalPath(idxkeep,:);
a=OptimalPath==b(1);
[~,I]=max(a);
OptimalPath=OptimalPath(1:I,:);

if size(OptimalPath,1)>2
    NewWPTn = cloudWPT (ACpos,OptimalPath,lat1,lon1);
    NewFP=[NewWPTn;WP];
else
    NewFP=WP;
end

if ~exist('NewWPT','var')
    NewWPT=[];
end
end