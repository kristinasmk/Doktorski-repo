function waypoints = waypointsclean (so6data)
%this function creates cleaned waypoint structure as it is used for tp mode
% it cleans all added waypoints during flight from historic data recorded
% in so6

    %this parts split all points and extract ending points
    
    points=so6data(:,1);
    points=split(points,'_',2);
    points=points(:,2);
    
    a=startsWith(points,'!');
    b=startsWith(points,'*');

    c=a|b;
    
    if min(c)==0
        points=points(~c,:);
        acdata=so6data(~c,:);
        
        for i=1:length(points)
            waypoints(i).y=cell2mat(acdata(i,15))/60;
            waypoints(i).x=cell2mat(acdata(i,16))/60;
            waypoints(i).z=cell2mat(acdata(i,8))*100*0.3048;
            waypoints(i).flyover=0;
            waypoints(i).hist=1;
            waypoints(i).name=points(i);
        end
    else
            waypoints.y=cell2mat(so6data(size(so6data,1),15))/60;
            waypoints.x=cell2mat(so6data(size(so6data,1),16))/60;
            waypoints.z=cell2mat(so6data(size(so6data,1),8))*100*0.3048;
            waypoints.flyover=0;
            waypoints.hist=1;
            waypoints.name=points(size(so6data,1));
    end

end

