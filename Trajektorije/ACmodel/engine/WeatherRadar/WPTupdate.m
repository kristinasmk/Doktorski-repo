function [WPTlist,WPTn] = WPTupdate (waypoints,WPTi,AstarGrid,FFP,CloudsAll,ACstate,...
    NeighboorsTable,cloudMap)

    %this function start astar algorithm to find best path to initial
    %Filed Flight Plan waypoint

    %selecting initial FFP wpt
    ch=extractfield(waypoints,'hist');
    if ch(WPTi)==0
        WPTffp=sum(ch(1:WPTi))+1; %all previous next wpt;
    else
        WPTffp=sum(ch(1:WPTi));
    end

    %Modified Astar
    [NewFP,NewWPT,WPTffpn] = AstarRoute_v4 (AstarGrid.lon1, AstarGrid.lon2, AstarGrid.lat1,...
        AstarGrid.lat2, CloudsAll, [ACstate(2),ACstate(1)],NeighboorsTable,...
        cloudMap,ACstate(5),FFP,WPTffp);

    d=WPTffpn-WPTffp;
    WPTi=WPTi+d;

    if ~isempty(NewWPT)
        %changing waypoints if current one is within polygon
        ch2=ch(WPTi:end);
        WPTffp2=find(ch2,1,'first');
        WPTffp2=WPTi+WPTffp2-1; %-1 is because in finding proccess 1 was added


        waypoints(WPTffp2).y=NewWPT(1);
        waypoints(WPTffp2).x=NewWPT(2);
    end

    if size(NewFP,1)>2

        WPTn=WPTi;
        WPTlist= wptcut (waypoints,NewFP,WPTi);
    end
end