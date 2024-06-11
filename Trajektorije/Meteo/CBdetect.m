function CBpos = CBdetect (CloudBin)
%this function will read Binary sum from processed image to locate local
%maximums which could represent cumulonimbus clouds
%script separate 7x7 matrix from CloudBin and finds local maximum
%Local maximums and surrounding cells (up/down,left/right) are indexed in
%potentialCB matrix
%potentialCB matrix is output of this function

n=size(CloudBin);
PotentialCB1=zeros(size(CloudBin,1)+3,size(CloudBin,2)+3);

for y=4:n(1)-3
    for x=4:n(1)-3
        CBmat=CloudBin(y-3:y+3,x-3:x+3);
        
        stats=[max(max(CBmat)),min(min(CBmat)),mean(mean(CBmat)),std(std(CBmat))];
        
        if stats(1)>28 && stats(2)>0
            %this if will remove low level clouds
            
            if (stats(1) - stats(2)) > 5
                %if there is logged altitude diference in cloud tops over
                %1500m this part of function will work. It will mark 1 in
                %binary matrix position of local maximum and also add 1 to
                %neigbour cells.
                
                [~,I] = max(CBmat(:));
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

PotentialCB1=flip(PotentialCB1(4:end,4:end));
CBpos=PotentialCB1;
%end