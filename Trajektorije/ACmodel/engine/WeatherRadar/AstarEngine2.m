%Example on the use of AStar Algorithm in an occupancy grid. 
clear
%%% Generating a MAP
 ACpos=[43 18];
WP=[46 18];
load clouds.mat
load NeighboorsTable2.mat

AstarGrid.lon1=12.5;
AstarGrid.lat1=41;
AstarGrid.lon2=19.5;
AstarGrid.lat2=47;

NewFP = AstarRoute (AstarGrid.lon1, AstarGrid.lon2, AstarGrid.lat1, AstarGrid.lat2, Clouds, ACpos, WP, NeighboorsTable);

