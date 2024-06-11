function [CloudsAll, cloudMap] = cloudM (Clouds,AstarGrid)
% this function merge all clouds in one variable for faster processing
% (CloudAll) and create map for Astar algorithm

%create one variable of cloud coordinates with NaN separating polygons
Cl=Clouds{(1)};
CloudsAll=Cl;    
    
    for i=2:size(Clouds,2)
        Cl=Clouds{(i)};
        CloudsAll=[CloudsAll;[NaN NaN NaN];Cl];
    end

%create map for Astar algorithm with all clouds    
lons=round((AstarGrid.lon2-AstarGrid.lon1)/4*60);
lats=round((AstarGrid.lat2-AstarGrid.lat1)/4*60);
MAP=int8(zeros(lats,lons));

for i=1:size(Clouds,2)
    c=Clouds{(i)};
    cy=round((AstarGrid.lat2 - c(:,1))/4*60);
    cx=round((c(:,2) - AstarGrid.lon1)/4*60);
    
    [x,y] = centroid(polyshape(cx,cy));
    cx(cx<x)=cx(cx<x)-1;
    cy(cy<y)=cy(cy<y)-1;
    
    mask=poly2mask(cx,cy,lats,lons);
    MAP=MAP+int8(mask);
end
MAP=MAP>0;
MAP=int8(MAP);
cloudMap=MAP;
end