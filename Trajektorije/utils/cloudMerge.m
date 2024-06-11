function [CloudsAll, cloudMap, CloudAlt,cloudMap3D] = cloudMerge (Clouds,AstarGrid)
% this function merge all clouds in one variable for faster processing
% (CloudAll) and create map for Astar algorithm


%this part will filter out all clouds with thickness of just 1 FL
Alt=[Clouds{:,1}];
Alt=(reshape(Alt,2,size(Alt,2)/2))';
Altd=(Alt(:,2)-Alt(:,1))>0;
Clouds=Clouds(Altd,:);

%create one variable of cloud coordinates with NaN separating polygons
Cl=Clouds{1,2};
Alt=Clouds{1,1};

Cl(:,3)=Alt(1);
Cl(:,4)=Alt(2);

CloudsAll=Cl;    
CloudAlt=cell(60,1);

for aspan=Alt(1):Alt(2)
    CloudAlt(aspan)={Cl};
end
    for i=2:size(Clouds,1)
        
        % OVDJE IDE ALGORITAM KOJI ÆE IGNORIRATI NEKE OD OBLAKA
        %
        %
        %
        
        Cl=Clouds{i,2};
        Alt=Clouds{i,1};
        Cl(:,3)=Alt(1);
        Cl(:,4)=Alt(2);
            %svi oblaci u 2d matrici
        CloudsAll=[CloudsAll;[NaN NaN NaN NaN];Cl];

        %svi oblaci podjeljeni po visinu
        for aspan=Alt(1):Alt(2)
            a=CloudAlt{aspan};
            CloudAlt(aspan)={[a;[NaN NaN NaN NaN];Cl]};
        end
    end

%create map for Astar algorithm with all clouds    
lons=round((AstarGrid.lon2-AstarGrid.lon1)/4*60);
lats=round((AstarGrid.lat2-AstarGrid.lat1)/4*60);
MAP=int8(zeros(lats,lons));

MAP3D=int8(zeros(lats,lons,60));

for i=1:size(Clouds,1)
    c=Clouds{i,2};
    cy=round((AstarGrid.lat2 - c(:,1))/4*60);
    cx=round((c(:,2) - AstarGrid.lon1)/4*60);
    
    [x,y] = centroid(polyshape(cx,cy));
    cx(cx<x)=cx(cx<x)-1;
    cy(cy<y)=cy(cy<y)-1;
    
    mask=poly2mask(cx,cy,lats,lons);
    MAP=MAP+int8(mask);
    
    %create 3D mask of clouds
     Alt=Clouds{i,1};
     if Alt(2)-Alt(1)>0
        for asp=Alt(1):Alt(2)
            MAP3D(:,:,asp)=MAP3D(:,:,asp)+int8(mask);
        end
     end
    
end
MAP=MAP>0;
MAP=int8(MAP);
cloudMap=MAP;

MAP3D=MAP3D>0;
MAP3D=int8(MAP3D);
cloudMap3D=MAP3D;
end