function NewWPTn = cloudWPT (ACpos,OptimalPath,lat1,lon1)
%this function will update waypoint list based on mitigating actions from
%Input variable:
   %    ACpos - currenct AC position
   %    OptimalPath - path calculated by Astar algorithm
   %    lat1 and lon1 - lat and lon of grid starting point
%Output:
   %    NewWPT - clean list of waypoints to avoid clouds
%ASTAR algorithm.

%this only works if Optimal path has more than 3 points

OptimalPath=unique(OptimalPath,'rows','stable');

w=1;
    for i=3:size(OptimalPath,1)
       hdg1=atan2(OptimalPath(i-1,1)-OptimalPath(i-2,1),OptimalPath(i-1,2)-OptimalPath(i-2,2));
       hdg2=atan2(OptimalPath(i,1)-OptimalPath(i-1,1),OptimalPath(i,2)-OptimalPath(i-1,2));
       
       if abs(hdg2-hdg1)>=0.03 %toelrancija od 3 stupnja
           Y=OptimalPath(i-1,1)/60+lat1;
           X=OptimalPath(i-1,2)/60+lon1;
           WP(w,:)=[Y,X];
           w=w+1;
       end
       
    end
    
    if exist('WP','var')==1
        NewWPT=[ACpos;WP];
    else
        NewWPT=ACpos;
    end
    
    if size(NewWPT,1)>1
    n=1;
        for d=2:size(NewWPT,1)
            dist=deg2nm(distance(NewWPT(d-1,1),NewWPT(d-1,2),NewWPT(d,1),NewWPT(d,2)));

            if dist>5
                WPn(n,:)=NewWPT(d,:);
                n=n+1;
            end
        end
        if exist('WPn','var')==1
            NewWPTn=[ACpos;WPn];
        else
            NewWPTn=ACpos;
        end
    else
        NewWPTn=NewWPT;
    end
end
