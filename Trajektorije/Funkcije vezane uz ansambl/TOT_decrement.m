%
function [ACarchO,TOT_increments] = TOT_decrement (ACarchive, time_to_EOBT, entrytime)

[~, TOT_increments] = TOT_uncertainty(time_to_EOBT, entrytime);

LT=ACarchive(:, 21);
ACarchO=zeros(size(ACarchive,1),size(ACarchive,2),length(TOT_increments)-1);


for i = 2:length(TOT_increments)
 transformed_increments(i) = TOT_increments(i)- TOT_increments(i-1);

 ACarchive(:, 21)=LT+transformed_increments(i);  
 ACarchO(:,:,i-1)=ACarchive;
 
end


