%probability matrix
% X-axis is % coverage with echo top >=
% 30 kft. (16 x 16 km); Y-axis is flight altitude – 90th
% percentile echo top (16 x 16 km).

RGBmatrix
RGBlegend

ProbM=zeros(11,11);
ProbL=1/64:1/64:1;


a=reshape(RGBprobab,[],1);
for p=1:size(a,1)
    for i=1:64
       if sum(a{(p)}==Legend(i,:))==3
           [r,c]=ind2sub([11 11],p);
           ProbM(r,c)=ProbL(i);
       end
    end
end

FlightALt_echotop=-20:4:20;
CoveragePercent_echotop=0:10:100;