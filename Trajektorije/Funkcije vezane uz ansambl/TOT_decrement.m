%this function changes the time of initially simulated route pa adding
%decrement or increment to the times according to TOT uncertainty
%Outputs: ACarchO contains trajectory data for all TOT members
%TOT_increments contain data how much time changes oer TOT member
function [ACarchO,TOT_increments] = TOT_decrement (ACarchive, time_to_EOBT, entrytime)

%this function calculates TOT_increments sbased on the TOT distribution
[~, TOT_increments] = TOT_uncertainty(time_to_EOBT, entrytime);

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


