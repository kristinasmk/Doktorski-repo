function [newPoint,WP] = pointshift (ACpos,WPin,cloud,Heading)
%this function will shift waypoint that is in cloud or close to cloud
%outside cloud

Heading = MathtoNavAngle (Heading);
oposit=Heading+180;

krug=circ([WPin(2),WPin(1)],nm2deg(4));
cross=polyxpoly(krug(:,2),krug(:,1),cloud(:,2),cloud(:,1));

if oposit>360
    oposit=oposit-360;
end

    if inpolygons(WPin(1),WPin(2),cloud(:,1),cloud(:,2)) == 1
     [WPx,WPy]=polyxpoly([ACpos(2) WPin(2)],[ACpos(1) WPin(1)],cloud(:,2),cloud(:,1));
     
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
     
     [WP(1),WP(2)]=reckon(WPy,WPx,nm2deg(5),oposit); % 5 is 5NM shift!
     
      newPoint=[WP(1),WP(2)];
      
    elseif isempty(cross)==1
     [WP2(1),WP2(2)]=reckon(WPin(1),WPin(2),nm2deg(3),oposit);
     
         if inpolygons(WP2(1),WP2(2),cloud(:,1),cloud(:,2)) == 1
             
             %this shift is if wpt is at other side of cloud
             [WP(1),WP(2)]=reckon(WPin(1),WPin(2),nm2deg(3),Heading); 
             newPoint=[WP(1),WP(2)];
     
         else
           WP(1)=WP2(1);
           WP(2)=WP2(2);
            newPoint=[WP2(1),WP2(2)];
         end
    else
        WP=WPin;
        newPoint=[];
    end
   
    
end