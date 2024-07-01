%%This function combines the data from so6 (slight_pos) and data from all
%%ft from nest (FPLintent) to stick EOBT time to the flight_pos data

function flight_pos = EOBTinput (FPLintent, flight_pos)
    if ~isfield(FPLintent, 'ACid') || ~isfield(FPLintent, 'eobt')
        error('FPLintent struct must contain fields ''ACid'' and ''eobt''.');
    end
    if ~isfield(flight_pos, 'name')
        error('flight_pos struct must contain field ''name''.');
    end
    
    numFPLintent = numel(FPLintent);
    numFlightPos = numel(flight_pos);
    
    for i = 1:numFPLintent
        currentACid = FPLintent(i).ACid;
        currentEobt = FPLintent(i).eobt;
        
        for j = 1:numFlightPos
            if isfield(flight_pos(j), 'name') && strcmp(flight_pos(j).name, currentACid)
                flight_pos(j).eobt = currentEobt;
            end
        end
    end
end
