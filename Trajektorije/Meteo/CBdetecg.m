%function CBpos = CBdetecg (CloudBin)
%this function will read Binary sum from processed image to locate local
%maximums which could represent cumulonimbus clouds

n=size(CloudBin);
PotentialCB1=zeros(size(CloudBin,1)+2,size(CloudBin,2)+2);
PotentialCB2=zeros(size(CloudBin,1)+2,size(CloudBin,2)+2);
PotentialCB3=zeros(size(CloudBin,1)+2,size(CloudBin,2)+2);

for y=3:n(1)-2
    for x=3:n(1)-2
        CBmat=CloudBin(y-2:y+2,x-2:x+2);
        
        stats=[max(max(CBmat)),min(min(CBmat)),mean(mean(CBmat)),std(std(CBmat))];
        
        if stats(1)>28 && stats(2)>0
            if (stats(1) - stats(2)) > 5
                
                [C,I] = max(CBmat(:));
                [I1,I2] = ind2sub(size(CBmat),I);
                PotentialCB1(y+I1,x+I2)=1;
                PotentialCB1(y+I1+1,x+I2)=1;
                PotentialCB1(y+I1,x+I2+1)=1;
                PotentialCB1(y+I1-1,x+I2)=1;
                PotentialCB1(y+I1,x+I2-1)=1;
            end

%             if stats(1) - stats(3) > 6
%                 [C,I] = max(CBmat(:));
%                 [I1,I2] = ind2sub(size(CBmat),I);
%                 PotentialCB2(y+I1,x+I2)=1;
%             end
% 
%             if (stats(1)-stats(2)) - stats(4) > 7
%                 [C,I] = max(CBmat(:));
%                 [I1,I2] = ind2sub(size(CBmat),I);
%                 PotentialCB3(y+I1,x+I2)=1;
%             end
        end
    end
end

PotentialCB1=flip(PotentialCB1(3:end,3:end));
PotentialCB2=flip(PotentialCB2(3:end,3:end));
PotentialCB3=flip(PotentialCB3(3:end,3:end));
%end