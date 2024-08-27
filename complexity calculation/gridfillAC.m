function [ACgrid] = gridfillAC (ACTP,polygon,p,ACname)
%this function will position aircraft withing grid cells of PRU grid

%find ac positions in PRU grid
[i,index]=inpolygons(ACTP(:,2),ACTP(:,1),polygon.xaxis(p,:),polygon.yaxis(p,:)); 

%filter ac position in PRU grid
ACTP=ACTP(i,:);

%find vertical position in PRU grid (Closest flight level. For the complexity
%calculation an aircraft must be added to upper and lower FL due to
%vertical cell shift.)
a=(round(ACTP(:,5)/10)*10)/10-9;

%add cell positions to AC data
%logged data goes as follows: [Lat,Lon,TAS,ROCD,FL,CRS,GS]
ACTP=[ones(size(ACTP,1),1)*ACname,ACTP,[index{i}]',a];
ACgrid=ACTP;
end