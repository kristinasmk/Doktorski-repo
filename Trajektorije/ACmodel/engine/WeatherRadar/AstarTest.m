%astar test

%Example on the use of AStar Algorithm in an occupancy grid. 
clear
%%% Generating a MAP
% ACpos=[44.5503619485148,19.0168710465122];
% WP=[42.6000000000000,19.0045609202657];
load clouds.mat

ACpos=[42.7284063239344,19.2555176975149];
WP=[43.1427777833333,18.5580555500000];

%ACpos=[44.633647459123760,15.566137940179892];

lon1=12.5;
lat1=41;
lon2=19.5;
lat2=47;
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
end
MAP=int8(MAP>0);


%Start Positions
StartY=round((ACpos(1)-lat1)*60);
StartX=round((ACpos(2)-lon1)*60);

Start=[StartX,StartY];
% a=ASl
%Start Positions
% StartX=5;
% StartY=99;

%Generating goal nodes, which is represented by a matrix. In 2sided version
%only one goal node can be specified



GoalY=round((WP(1)-lat1)*60);
GoalX=round((WP(2)-lon1)*60);


%CONNECTING DISTANCEA
D=sqrt((StartX-GoalX)^2+(StartY-GoalY)^2);
Connecting_Distance=D-2;
if Connecting_Distance<1
    Connecting_Distance=1;
    
elseif Connecting_Distance>20
    Connecting_Distance=20;
end


% A MORE EFFICIENT SOLVER
load NeighboorsTable2 NeighboorsTable
Neighboors=NeighboorsTable{Connecting_Distance};


%THE MOST EFFICIENT SOLVER; TWO SIDED SOVLER (ALSO 
OptimalPath=ASTARPATH2SIDED(StartX,StartY,MAP,GoalX,GoalY,Connecting_Distance,Neighboors);





% ovaj dio dolje je samo za prikaz rješenja, osim toga je bezveze
if size(OptimalPath,2)>1
figure(10)
imagesc(MAP)

    colormap(flipud(gray));

hold on
plot(OptimalPath(1,2),OptimalPath(1,1),'o','color','k')
plot(OptimalPath(end,2),OptimalPath(end,1),'o','color','b')
plot(OptimalPath(:,2),OptimalPath(:,1),'r')
legend('Goal','Start','Path')

%USE LENGTH TO NEAREST WALL IN OCCUPANCY GRID AS A SIMPLE GRIDDER TO UPDATE CLOSEMAP?. LOGIC?

%Version 1.0

else 
     pause(1);
 h=msgbox('Sorry, No path exists to the Target!','warn');
 uiwait(h,5);
 end









showNeighboors=0; %Set to 1 if you want to visualize how the possible directions of path. The code
%below are purley for illustrating purposes. 
if showNeighboors==1
        figure('name','Con1')
PlotConnectors(Connecting_Distance)
end