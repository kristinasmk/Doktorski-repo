function NewWPTlist = wptcut (waypoints,NewFP,WPTi)
%this function will update waypoint list by cutting old waypoints and
%refreshing list with new. It will keep original points and passed points


NewFP(:,3)=waypoints(WPTi).z;
NewFP(:,4)=1;

A=waypoints(1:WPTi-1);

for w=1:size(NewFP,1)
   B(w).y=NewFP(w,1);
   B(w).x=NewFP(w,2);
   
   if size(waypoints,1)>WPTi
   B(w).z=waypoints(WPTi+1).z;
   else
   B(w).z=waypoints(WPTi).z;
   end
   
   B(w).flyover=1;
   B(w).hist=0;
   B(w).name={'addedWPT'};
end

C=waypoints(WPTi:end);
ch=extractfield(C,'hist');
ch=ch==1;
C=C(ch);  

NewWPTlist=[A,B(2:end-1),C];


end