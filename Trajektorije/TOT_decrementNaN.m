%this function changes the time of initially simulated route pa adding NaN
%to routes without TOT unceratinty 
function [ACarchO] = TOT_decrementNaN (ACarchive, TOT_time_sec)

ACarchO=zeros(size(ACarchive,1),size(ACarchive,2),length(TOT_time_sec));

for i = 1:length(TOT_time_sec)
    if i == 1
 ACarchive(:,:,i) = ACarchive;
    else
        ACarchive(:,21) = TOT_time_sec(i);
    end
    if isnan(TOT_time_sec(i))
        ACarchive = NaN;
    end
 ACarchO(:,:,i)=ACarchive;
end

