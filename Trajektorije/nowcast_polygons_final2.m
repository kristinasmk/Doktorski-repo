function [polygons3d, NumOfNowcastMembers, NumOfSafetyMargins] = nowcast_polygons_final2(nowcast, safetyMargins)
    load('nowcast_without_margin.mat')
    lead_time = nowcast.lead_times;
    nowcast_members = nowcast.nowcast_members;
    reference_time = nowcast.reference_time;
    geometries = nowcast.geometries;
    safety_margin = nowcast.safety_margin;

    % Get unique lead times and number of different nowcast members
    NumOfLeadTimes = unique([geometries.lead_time]');
    NumOfNowcastMembers = max(nowcast_members);
    % Provide an input of how many safety margins will be considered
    NumOfSafetyMargins = 3;

    % Convert reference time to seconds
    referenceTime = datetime(reference_time, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
    referenceTimeInSeconds = hour(referenceTime) * 3600 + minute(referenceTime) * 60 + second(referenceTime);

    % Initialize the 4D matrix
    polygons3d = cell(numel(NumOfLeadTimes), 3, NumOfNowcastMembers, NumOfSafetyMargins);

    %Upisati koje vrijednosti želim
   

    for safetyMarginIndex = 1:NumOfSafetyMargins
        CurrentMargin = safetyMargins(safetyMarginIndex);
        nfz_cell = nfz_exec_v2(nowcast, CurrentMargin);
        %save 'D:\nfz_cell.mat';

        for i = 1:numel(geometries)
            leadTime = geometries(i).lead_time;
            nowcastMember = geometries(i).nowcast_member;
                      
            % Find the index of the current lead time
            leadTimeIndex = find(NumOfLeadTimes == leadTime);

            % Convert lead time to seconds
            leadTimeInSeconds = leadTime + referenceTimeInSeconds;

            % Create a cell array to hold altitude and coordinates for each cloud
            numClouds = numel(nfz_cell{leadTimeIndex, nowcastMember});
            cloudData = cell(numClouds, 3);
            cloudDataCoords = cell(1, numel(nfz_cell{leadTimeIndex, nowcastMember}))';
            
            % Access cloud coordinates from nfz_cell
            for cloudIndex = 1:numel(nfz_cell{leadTimeIndex, nowcastMember})
                lon = nfz_cell{leadTimeIndex, nowcastMember}(cloudIndex).Lon;
                lat = nfz_cell{leadTimeIndex, nowcastMember}(cloudIndex).Lat;
                
                cloudDataCoords{cloudIndex} = [lat, lon];
            end
                      
            
            cth = geometries(i).CTH;
            firstCTH = cth(find(~isnan(cth), 1));

            % Create the altitude vector with a fixed value for all clouds
            altitudeVector = [1, ceil((firstCTH * 3.28084 / 100) + 50)];
            
            
            for cloudIndex = 1:numel(nfz_cell{leadTimeIndex, nowcastMember})
                cloudData{cloudIndex,1} = altitudeVector;
                cloudData{cloudIndex,2} = cloudDataCoords{cloudIndex};
                cloudData{cloudIndex,3} = cloudDataCoords{cloudIndex};
            end

            % Assign the cloud data to the corresponding position in the polygons matrix
            polygons3d{leadTimeIndex, 1, nowcastMember, safetyMarginIndex} = leadTime;
            polygons3d{leadTimeIndex, 2, nowcastMember, safetyMarginIndex} = leadTimeInSeconds;
            polygons3d{leadTimeIndex, 3, nowcastMember, safetyMarginIndex} = cloudData;
        end
    end

  
    save('polygons3d.mat', 'polygons3d');
end
