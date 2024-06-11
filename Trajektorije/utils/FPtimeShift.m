function [flight_pos_ts] = FPtimeShift (flight_pos,traffTime,CloudTime)
%this function will shift spawn time of aircraft to match time of selected
%cloud situation
flight_pos_ts=flight_pos;

if traffTime~=CloudTime
    for i=1:size(flight_pos,2)
        flight_pos_ts(i).spawntime=flight_pos(i).spawntime+(CloudTime-traffTime)*3600;
    end
end
end