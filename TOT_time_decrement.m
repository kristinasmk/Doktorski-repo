function [ACarchive] = TOT_decrement (ACarchive, time_to_EOBT, entrytime, totIndex)

[TOT_time_sec, TOT_increments] = TOT_uncertainty(time_to_EOBT, entrytime);

ACarchive(:,21) = ACarchive(:,21) + TOT_increments(totIndex);

end