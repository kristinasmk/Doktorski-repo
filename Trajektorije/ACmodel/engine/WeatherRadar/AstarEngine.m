
%Example on the use of AStar Algorithm in an occupancy grid. 
clear
%%% Generating a MAP
ACpos=[44 16];
WP=[42 18];
load clouds.mat

lon1=12.5;
lat1=41;
lon2=19.5;
lat2=47;
lons=round((lon2-lon1)*60/4);
lats=round((lat2-lat1)*60/4);


%1 represent an object that the path cannot penetrate, zero is a free path
MAP=int8(zeros(lats,lons));

for i=1:size(Clouds,2)
    c=Clouds{(i)};
    cy=round((c(:,1)-lat1)*60/4);
    cx=round((c(:,2)-lon1)*60/4);
    mask=poly2mask(cy,cx,lats,lons);
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
    end
end
MAP=int8(MAP>0);


%Start Positions
StartX=round((ACpos(1)-lat1)*60/4);
StartY=round((ACpos(2)-lon1)*60/4);

Start=[StartX,StartY];


%Generating goal nodes, which is represented by a matrix. In 2sided version
%only one goal node can be specified

GoalX=round((WP(1)-lat1)*60/4);
GoalY=round((WP(2)-lon1)*60/4);


%CONNECTING DISTANCEA
Connecting_Distance=20;


% A MORE EFFICIENT SOLVER
load NeighboorsTable2 NeighboorsTable
Neighboors=NeighboorsTable{Connecting_Distance};


%THE MOST EFFICIENT SOLVER; TWO SIDED SOVLER (ALSO 
OptimalPath=ASTARPATH2SIDED(StartX,StartY,MAP,GoalX,GoalY,Connecting_Distance,Neighboors);

if size(OptimalPath,1)>2
    NewWPTn = cloudWPT (ACpos,OptimalPath,lat1,lon1);
    NewFP=[NewWPTn;WP];
else
    NewFP=WP;
end
