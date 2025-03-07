function [NewFP,NewWPT,WPTffp] = AstarRoute_v4 (lon1, lon2, lat1, lat2, CloudsAll,...
    ACpos, NeighboorsTable,cloudMap, Heading, FFP, WPTffp)
%function 

lons=round((lon2-lon1)/4*60);
lats=round((lat2-lat1)/4*60);

if WPTffp>size(FFP,2)
    WPTffp=size(FFP,2);
end

WP=[FFP(WPTffp).y,FFP(WPTffp).x];

% ova petlja bi trebala maknuti uzastopne to�ke koje su u oblaku
wp=WPTffp;
WPt=[FFP(WPTffp).y,FFP(WPTffp).x];

while inpolygons(WPt(1),WPt(2),CloudsAll(:,1),CloudsAll(:,2)) == 1
    wp=wp+1;
    if wp>size(FFP,2)
        wp=wp-1;
        break
    end    
    WPt=[FFP(wp).y,FFP(wp).x];
end

if wp>2
    WP=[FFP(wp).y,FFP(wp).x];
    WPTffp=wp;
end

%1 represent an object that the path cannot penetrate, zero is a free path

    %ovaj dio koda provjerava je li waypoint u oblaku i ako je prebacuje ga
    %po kursu ispred oblaka
       
    [NewWPT,WP] = pointshift (ACpos,WP,CloudsAll,Heading);
    
    %this part of function will check if ac position is in polygon (cloud), if it
    %is it will shift it along desired path to be outside for astar to work
    if inpolygons(ACpos(1),ACpos(2),CloudsAll(:,1),CloudsAll(:,2)) == 1
        [ACPx,ACPy]=polyxpoly([ACpos(2) WP(2)],[ACpos(1) WP(1)],CloudsAll(:,2),CloudsAll(:,1));
        
        Dist2=zeros(size(ACPx,1),1);
     for d=1:size(ACPx,1)
         Dist2(d)=(sqrt((ACpos(2)-ACPx(d))^2+(ACpos(1)-ACPy(d))^2));
     end
     
     ACPx=ACPx(Dist2==min(Dist2));
     ACPy=ACPy(Dist2==min(Dist2));
        
        if ACPx>ACpos(2)
          ACPx=ACPx+0.04; %0.04 stupanj se dodaje jer polyxpoly stavlja to�ku na sam rub
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

gaps=bwboundaries(~MAP,'noholes');
if size(gaps,1)>1
    holes=cellfun(@numel,gaps);
    holes=~(holes==max(holes));
    gaps2=gaps(holes);
   for g=1:size(gaps2,1)
       ga=gaps2{g};
       MAP(ga(:,1),ga(:,2))=1; 
   end
end


%Start Positions
StartY=round((lat2-ACpos(1))/4*60);
StartX=round((ACpos(2)-lon1)/4*60);

if StartX <=0
    StartX =1;
elseif StartY <=0
    StartY =1;
end

%Generating goal nodes, which is represented by a matrix. In 2sided version
%only one goal node can be specified

GoalY=round((lat2-WP(1))/4*60);
GoalX=round((WP(2)-lon1)/4*60);

while StartY == GoalY && StartX == GoalX 
%     if WPTffp > size(FFP,2)
%         error('Nije dobro');
%     end
    WPTffp=WPTffp+1;
    [NewWPT,WP] = pointshift (ACpos,WP,CloudsAll,Heading);
    GoalY=round((lat2-WP(1))/4*60);
    GoalX=round((WP(2)-lon1)/4*60);
end

if GoalX<=0
    GoalX=1;
end

if GoalY<=0
    GoalY=1;
end

if MAP(GoalY,GoalX) == 1
    [GoalX,GoalY]= AstarPointshift (GoalX, GoalY, MAP);
end

if MAP(StartY,StartX) == 1
    [StartX,StartY]= AstarPointshift (StartX, StartY, MAP);
end

if StartY == GoalY && StartX == GoalX
    [StartX,StartY]= AstarPointshift (StartX, StartY, MAP);
end

%CONNECTING DISTANCEA
D=floor((sqrt((StartX-GoalX)^2+(StartY-GoalY)^2)));
Connecting_Distance=D;
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
A=OptimalPath==OptimalPath(1,:);
B=OptimalPath==OptimalPath(end,:);
if sum(A(:,1))>1 || sum(B(:,1))>1
    OptimalPath = OptPathClean (OptimalPath,GoalX,GoalY);
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