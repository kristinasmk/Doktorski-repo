function [randomAC,newusedACdata] = randomACf (usedACdata,ws)
%this function will take binary matric of previously used AC TPs in
%caluclation, randomly take one of TPs that has not been previously used
%and return new binary matric

l=0:15:size(usedACdata);
l=l(1:end-1);

% if max(max(usedACdata))==0
%     usedACdata=repmat(1:5,size(usedACdata,1),1);
% end

%since there are multiple aircraft TPs one will be selected by random
%traffic scenario ts (for aircraft with multiple TP per ts this number is random)
if size(l,2)>1
    if max(max(usedACdata(ws+l,:)))==0
        A=usedACdata(ws+l,:);
        for i=1:size(A,1)
            usedACdata(ws+l(i),:)=1:5;
        end
    end
    ts=ws+l(randperm(length(l),1)); 
    %if randomly selected weather scenario doesnt have any available TPs
    %but there are other TPs of same weather scenario new TP will be
    %selected
    while max(usedACdata(ts,:))==0
        l=l(l~=(ts-ws));
        ts=ws+l(randperm(length(l),1));
    end
else
    if max(usedACdata(ws,:))==0
        usedACdata(ws,:)=1:5;
    end
    ts=ws;
end
%select random safety factor
sf=usedACdata(ts,usedACdata(ts,:)>0);
ind=randperm(numel(sf),1);
sf=sf(ind);

if usedACdata(ts,sf)==0
    while usedACdata(ts,sf)==0
        %since there are multiple aircraft TPs one will be selected by random
        %traffic scenario ts (for aircraft with multiple TP per ts this number is random)
        if size(l,1)>1
            ts=ws+l(randperm(length(l),1)); %should be created algorith for randomising
        else
            ts=ws;
        end
        %select random safety factor
        sf=usedACdata(ts,usedACdata(ts,:)>0);
        ind=randperm(numel(sf),1);
        sf=sf(ind);
    end
end

usedACdata(ts,sf)=0;
randomAC=[ts,sf];
newusedACdata=usedACdata;

end