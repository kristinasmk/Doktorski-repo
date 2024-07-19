function [cplx,cplxtc] = PRUcomplexf (cplxindicators,configmask)
%this function calculates complexity for desired sector configurations
%cplxindicators 4D matrix: 
% 1st dimension one of each indicator as fallow:
%       [FT,TX,TXV,TXH,TXS] %should be[FT,TX,TXV,TXH,TXS,TXC]
% 2nd dimension cell number
% 3rd dimension altitude position
% 4th dimension cellshift

%trenutno ogranicene ove funkcije je da radi na minimalno 2 timeframa. Ne
%može samo s jednim (primjer cplxindicators(:,1,:,:,:))

Cmask=zeros(size(configmask{1}{1},1)*size(configmask{1}{1},2),size(configmask{1}{1},3),4);
cplx=zeros(size(configmask,1),1); 


%for every sector PRU complexity is calculated
    for s=1:size(configmask,2)  %merge sector mask grid shifts into one
         CM=Cmask;
        for p=1:4
            mask=reshape(configmask{s}{p},[size(configmask{1}{1},1)*size(configmask{1}{1},2),...
                size(configmask{1}{1},3)]);
            CM(:,:,p)=mask; %configmask{s,p}; dok se ne na?e drugo rješene same jedna maska
        end
       
       inids=cplxindicators;
       
       inids=permute(inids,[2,3,4,1]); %shift indicator value at last spot
       %bsxfun multiplies CM matrix with every last dimension of inids
       %matrix (example for AxBxH matrix with bsxfun new matrix of A1xB1
       %will be multiplied with every H of first matrix
       inids=bsxfun(@times,inids,CM);
       
       %current indis order [cell,altitude,shift,indicators]
       
       %merge grids into one by putting shift in first dimension and
       %summing it
       inids=permute(sum(permute(inids,[3,1,2,4])),[2,3,4,1]); 
       % dimensions are [cell,altitide,indicator]
       
       %calculating total complexity
       inids2=permute(sum(sum(inids)),[3,1,2]); %one dimension left [indicators]
       
       %cplx(s,1)=(inids(3)+inids(4)+inids(5))/inids(1);    %without cloud
       cplx(s,1)=(inids2(3)+inids2(4)+inids2(5)+inids2(6))/inids2(1); %with clouds
       
       
       %calculating total complexity per cell
       %indistc=permute(inids,[2,1,3]);
       %indistc=permute(sum(indistc),[2,3,1]); %two dimensions left [cells indicators]
       for n=1:36
        B=(inids(:,n,3)+inids(:,n,4)+inids(:,n,5)+inids(:,n,6))./inids(:,n,1)*60;
        B(isnan(B))=0;
        cplxtc(s,n)={B}; 
       end
       
    end


end