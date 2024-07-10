%
function [ACarchO,TOT_increments] = TOT_decrement (ACarchive, time_to_EOBT, entrytime)

[~, TOT_increments] = TOT_uncertainty(time_to_EOBT, entrytime);

LT=ACarchive(:, 21);
ACarchO=zeros(size(ACarchive,1),size(ACarchive,2),length(TOT_increments));


for i = 1:length(TOT_increments)
    if i == 1
        transformed_increments(i) = 0;
    else
 transformed_increments(i) = TOT_increments(i)- TOT_increments(i-1);
    end
 ACarchive(:, 21)=ACarchive(:, 21)+transformed_increments(i);  
 ACarchO(:,:,i)=ACarchive;
 
end


