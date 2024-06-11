function [newpointX,newpointY]= AstarPointshift (oldpointX, oldpointY, MAP)
%this function will shift astar point out of polygon if it is in polygon 

sx=oldpointX-2;
ex=oldpointX+2;

if sx<1
    sx=1;
elseif ex>size(MAP,2)
    ex=size(MAP,2);
end

sy=oldpointY-2;
ey=oldpointY+2;

if sy<1
    sy=1;
elseif ey>size(MAP,1)
    ey=size(MAP,1);
end

subMAP=MAP(sy:ey,sx:ex);

if sum(sum(subMAP))==numel(subMAP)
    sx=oldpointX-20;
    ex=oldpointX+20;

    if sx<1
        sx=1;
    elseif ex>size(MAP,2)
        ex=size(MAP,2);
    end

    sy=oldpointY-20;
    ey=oldpointY+20;

    if sy<1
        sy=1;
    elseif ey>size(MAP,1)
        ey=size(MAP,1);
    end
    
    subMAP=MAP(sy:ey,sx:ex);
end


[r,c]=find(subMAP==0);
D=zeros(size(r,1),1);

    for i=1:size(r,1) 
        D(i)=sqrt((c(i)-3)^2+(r(i)-3)^2);       
    end

[~,I]=min(D);

newpointX=sx+c(I)-1;  %substract one since it starts from 1 and not 0
newpointY=sy+r(I)-1;

end