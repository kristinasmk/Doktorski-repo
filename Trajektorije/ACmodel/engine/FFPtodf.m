function [FFPtod] = FFPtodf (waypoints)
%this function will ad TOD to FFP without changing added wpts

L=extractfield(waypoints,'name');
for i=1:size(L,2)
    Li(i)=L{i};
end
Li=strcmp(Li,'addedWPT');
FFPtod=waypoints(~Li);
end