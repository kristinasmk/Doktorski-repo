function [CT] = CloudTest (ACstate,Cloud)
%this function simulates ac vector for lookahead 80 NM
%if radar vector will cross Cloud CT will be 1 if not it will be 0

Heading = MathtoNavAngle (ACstate(5));
ACpos=[ACstate(1) ACstate(2)];

%range of radar
Range=nm2deg(80); %radar range 80 NM


Radarpoint=reckon(ACpos(2),ACpos(1),Range,Heading);

Radarline(1,:)=[ACpos(2) Radarpoint(1)];
Radarline(2,:)=[ACpos(1) Radarpoint(2)];
[cx,cy]=polyxpoly(Radarline(1,:),Radarline(2,:),Cloud(:,1),Cloud(:,2));

if isempty(cx)==1
  
    CT=0;
else
    CT=1;
end
    

end

