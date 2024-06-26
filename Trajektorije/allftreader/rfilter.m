function froute = rfilter (raw_route)
 %this function will filter all automaticly generated route points marked
 %with ! or * in ALL_FT+ file
 
 points1=~contains(raw_route(:,2),'!');
 points2=~contains(raw_route(:,2),'*');
 points=points1&points2;
 
 froute=raw_route(points,:);
 
 
end