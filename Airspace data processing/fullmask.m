function [fmask] = fullmask (emask)
% this function will search through initial mask searching for holes in
% polygone and filling it with ones
%example line of mask is 000010000100000 and code will fill it with 
%ones 000011111100000

%horizontal
for m=1:size(emask,1)
    if sum(emask(m,:))>1
        f=find(emask(m,:),1,'first'); %find first 1
        l=find(emask(m,:),1,'last');   %find last 1
        emask(m,f:l)=1; %put ones in between first and last
    end
end
%vertical
for v=1:size(emask,2)
    if sum(emask(:,v))>1
        f=find(emask(:,v),1,'first'); %find first 1
        l=find(emask(:,v),1,'last');   %find last 1
        emask(f:l,v)=1; %put ones in between first and last
    end
end

    fmask=emask;
end