function [WPTlist,FFPnew] = WPTupdateCloud (WPT,waypoints,WPTi,FFP,WPTffp)
%this function will add waypoint for getting out of cloud WPT to waypoint
%list
%it will segment original waypoint list and add new waypoint (B) to
%waypoint list

A=waypoints(1:WPTi-1);
for i=1:size(A,2)
    if A(i).hist==0
        A(i).hist=1;
    end
end

B.y=WPT(2);
B.x=WPT(1);
B.z=waypoints(WPTi).z;
B.flyover=0;
B.hist=1;
B.name={'CloudOut'};
C=waypoints(WPTi:end);

points=extractfield(C,'name');
for i=1:size(points,2)
   points(i)=points{i}; 
end

points=strcmp(points,'addedWPT');
C=C(~points);

WPTlist=[A,B,C];

D=FFP(WPTffp:end);
FFPnew=[A,B,D];
end

