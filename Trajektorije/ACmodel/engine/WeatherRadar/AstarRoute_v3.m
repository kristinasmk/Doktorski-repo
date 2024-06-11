function [NewFP,NewWPT] = AstarRoute_v3 (lon1, lon2, lat1, lat2, CloudsAll,...
    ACpos, WP, NeighboorsTable,cloudMap)
%function 

lons=round((lon2-lon1)/4*60);
lats=round((lat2-lat1)/4*60);


%1 represent an object that the path cannot penetrate, zero is a free path

    %ovaj dio koda provjerava je li waypoint u oblaku i ako je prebacuje ga
    %po kursu ispred oblaka
    if inpolygons(WP(2),WP(1),CloudsAll(:,2),CloudsAll(:,1)) == 1
     [WPx,WPy]=polyxpoly([ACpos(2) WP(2)],[ACpos(1) WP(1)],CloudsAll(:,2),CloudsAll(:,1));
     
     Dist=zeros(size(WPx,1),1);
     for d=1:size(WPx,1)
         Dist(d)=(sqrt((ACpos(2)-WPx(d))^2+(ACpos(1)-WPy(d))^2));
     end
     
     WPx=WPx(Dist==max(Dist));
     if length(WPx)>1
         WPx=WPx(1);
     end
     WPy=WPy(Dist==max(Dist));
     if length(WPy)>1
         WPy=WPy(1);
     end
     
      if WPx>WP(2)
          WPx=WPx+0.1; %0.1 stupanj se dodaje jer polyxpoly stavlja toèku na sam rub
      elseif WPx<WP(2)
          WPx=WPx-0.1;
      end
      
      if WPy>WP(1)
          WPy=WPy+0.1;
      elseif WPy<WP(1)
          WPy=WPy-0.1;
      end
      WP(2)=WPx;
      WP(1)=WPy;
      NewWPT=[WPy,WPx]; 
    end
    
    %this part of function will check if ac position is in polygon (cloud), if it
    %is it will shift it along desired path to be outside for astar to work
    if inpolygons(ACpos(2),ACpos(1),CloudsAll(:,2),CloudsAll(:,1)) == 1
        [ACPx,ACPy]=polyxpoly([ACpos(2) WP(2)],[ACpos(1) WP(1)],CloudsAll(:,2),CloudsAll(:,1));
        
        Dist2=zeros(size(ACPx,1),1);
     for d=1:size(ACPx,1)
         Dist2(d)=(sqrt((ACpos(2)-ACPx(d))^2+(ACpos(1)-ACPy(d))^2));
     end
     
     ACPx=ACPx(Dist2==min(Dist2));
     ACPy=ACPy(Dist2==min(Dist2));
        
        if ACPx>ACpos(2)
          ACPx=ACPx+0.04; %0.04 stupanj se dodaje jer polyxpoly stavlja toèku na sam rub
        elseif ACPx<ACpos(2)
          ACPx=ACPx-0.04;
        end
      
      if ACPy>ACpos
          ACPy=ACPy+0.04;
      elseif ACPy<ACpos
          ACPy=ACPy-0.04;
      end
      ACpos(2)=ACPx;
      ACpos(1)=ACPy; 
    end

MAP=cloudMap;
MAP=int8(MAP>0);

%Start Positions
StartY=round((lat2-ACpos(1))/4*60);
StartX=round((ACpos(2)-lon1)/4*60);

%Generating goal nodes, which is represented by a matrix. In 2sided version
%only one goal node can be specified

GoalY=round((lat2-WP(1))/4*60);
GoalX=round((WP(2)-lon1)/4*60);

if MAP(GoalY,GoalX) == 1
    gx=[MAP(GoalY,GoalX-1),MAP(GoalY,GoalX+1)];
    if min(gx)==0
        g=find(gx==0);
        if g==1
            GoalX=GoalX-1;
        elseif g==2
            GoalX=GoalX+1;
        end
    end
    
    gy=[MAP(GoalY-1,GoalX),MAP(GoalY+1,GoalX)];
    if min(gy)==0
        g=find(gy==0);
        if g==1
            GoalY=GoalY-1;
        elseif g==2
            GoalY=GoalY+1;
        end
    end
end


%CONNECTING DISTANCEA
D=floor((sqrt((StartX-GoalX)^2+(StartY-GoalY)^2)));
Connecting_Distance=D-2;
if Connecting_Distance<1
    Connecting_Distance=1;

elseif Connecting_Distance>20
    Connecting_Distance=20;
end


% A MORE EFFICIENT SOLVER

Neighboors=NeighboorsTable{Connecting_Distance};


%THE MOST EFFICIENT SOLVER; TWO SIDED SOVLER (ALSO 
OptimalPath=ASTARPATH2SIDED(StartX,StartY,MAP,GoalX,GoalY,Connecting_Distance,Neighboors);

%cleaning a bit - finding points that repeat and removing them (two
%possible paths)
[~,idxu,idxc] = unique(OptimalPath,'rows');
if length(OptimalPath) ~= length(idxc)
    [count, ~, idxcount] = histcounts(idxc,numel(idxu));
    idxkeep = count(idxcount)>1;
    b=OptimalPath(idxkeep,:);
    a=OptimalPath==b(1);
    [~,I]=max(a);
    OptimalPath=OptimalPath(1:I,:);
end

if size(OptimalPath,1)>2
    NewWPTn = cloudWPT_v2 (ACpos,OptimalPath,lat2,lon1);
    NewFP=[NewWPTn;WP];
else
    NewFP=WP;
end
   


if ~exist('NewWPT','var')
    NewWPT=[];
end
end