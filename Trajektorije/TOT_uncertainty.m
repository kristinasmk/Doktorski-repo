function TOT_time_sec = TOT_uncertainty(time_to_EOBT, departure_planned_time)
    % Define the intervals (in minutes)
    
    time_to_EOBT = 30; %in minutes
    departure_planned_time = 30000;
    intervals = [0, 15; 15, 30; 30, 60; 60, 90; 90, 120; 120, 180; 180, 240; 240, 360];

    % Define the departure times for each interval (in minutes)
    TOT_increments = {
        [-11.99, -5.30, -3.00, -1.00, 0.01, 2.00, 4.99, 8.00, 14.00, 32.99], ...
        [-13.63, -6.99, -4.00, -1.99, 0.99, 3.01, 6.01, 10.01, 17.69, 38.00], ...
        [-15.21, -7.99, -4.73, -2.00, 0.01, 3.01, 6.01, 10.99, 18.99, 40.98], ...
        [-17.00, -8.98, -5.00, -2.43, 0.01, 3.00, 6.78, 11.51, 20.00, 43.99],...
        [-17.88, -9.00, -5.00, -2.03, 0.03, 3.01, 7.00, 12.00, 20.00, 43.01], ...
        [-38.81, -12.97, -7.01, -3.36, -0.05, 2.99, 6.99, 12.61, 21.99, 48.03], ...
        [-63.53, -16.22, -8.15, -4.04, -0.98, 2.96, 7.01, 13.02, 23.08, 52.00], ...
        [-51.80, -11.12, -6.05, -2.98, 0.02, 3.10, 7.48, 13.10, 23.83, 52.10],
    };

    % Convert to seconds
    for i = 1:length(TOT_increments)
        TOT_increments{i} = TOT_increments{i} * 60;
    end
    
    % Find the correct interval
    interval_index = 0;
    for i = 1:size(intervals, 1)
        if time_to_EOBT > intervals(i, 1) && time_to_eobt <= intervals(i, 2)
            interval_index = i;
            break;
        end
    end
    
    if interval_index == 0
        error('Time to EOBT must be within the defined intervals.');
    end
    
    selected_dep_times = TOT_increments{interval_index};
    TOT_times_sec = departure_planned_time + selected_dep_times;
end
