function [polygons3d, NumOfNowcastMembers] = nowcast_polygons_final (nowcast)
load('nowcast_without_margin.mat')
lead_time = nowcast.lead_times;
nowcast_members = nowcast.nowcast_members;
reference_time = nowcast.reference_time;
geometries = nowcast.geometries;
safety_margin = nowcast.safety_margin;


% Get unique lead times and number of different nowcast members
NumOfLeadTimes = unique([geometries.lead_time]');
NumOfNowcastMembers = max(nowcast_members);
%Provide an input of how many safety margins will be considered
NumOfSafetyMargins = 3;

% Convert reference time to seconds
referenceTime = datetime(reference_time, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
referenceTimeInSeconds = hour(referenceTime) * 3600 + minute(referenceTime) * 60 + second(referenceTime);

% Initialize the 3D matrix
polygons3d = cell(numel(NumOfLeadTimes), 3, NumOfNowcastMembers, NumOfSafetyMargins);

safetyMargins = [10, 12.5, 15];


for i = 1:numel(geometries)
    leadTime = geometries(i).lead_time;
    nowcastMember = geometries(i).nowcast_member;
    
    nfz_cell = nfz_exec_v2(nowcast);
    lon = nfz_cell(leadTime, nowcastMember).Lon;
    lat = nfz_cell(leadTime, nowcastMember).Lat;
    cth = geometries(i).CTH;
    
    % Find the index of the current lead time 
    leadTimeIndex = find(NumOfLeadTimes == leadTime);
    
    % Convert lead time to seconds
    leadTimeInSeconds = leadTime + referenceTimeInSeconds;
    
    % Find the indices where NaN occurs in the CTH variable to identify separate clouds
    nanIndices1 = find(isnan(cth));
    nanIndices2 = find(isnan(lat));
    
    % Determine the number of clouds in the lead time
    if isempty(nanIndices1)
        % No NaN values, only one cloud
        numClouds = 1;
        nanIndices1 = numel(cth) + 1;
    else
        % Number of clouds is determined by the number of NaN indices
        numClouds = numel(nanIndices1) + 1;
    end
    
    % Create a cell to hold altitude and coordinates for each cloud
    cloudData = cell(numClouds, 3);
    
    % Populate the cell with altitude and coordinates data for each cloud
    cloudIndex = 1;  % Counter variable for clouds
    
    for j = 1:numel(nanIndices1)+1
        if j == 1
            startIndex1 = 1;
        else
            startIndex1 = nanIndices1(j-1) + 1;
        end
        
        if j <= numel(nanIndices1)
            endIndex1 = nanIndices1(j) - 1;
        else
            endIndex1 = numel(cth);
        end
        
        % Create the altitude vector with a zero value at the beginning
        altitudeVector = [1, ceil((cth(startIndex1:endIndex1)*3.28084/100)+50)];
        cloudData{cloudIndex, 1} = altitudeVector;
         cloudIndex = cloudIndex + 1;
    end
    
    cloudIndex2 = 1;
    
    for k = 1:numel(nanIndices2)+1
        
        if k == 1
            startIndex2 = 1;
        else
            startIndex2 = nanIndices2(k-1) + 1;
        end
        
        if k <= numel(nanIndices2)
            endIndex2 = nanIndices2(k) - 1;
        else
            endIndex2 = numel(lat);
        end
        % Find the corresponding indices for coordinates
        coordIndices = startIndex2:endIndex2;
        
        % Store the coordinates per cloud in a cell array
       coordinates = [lat(coordIndices), lon(coordIndices)];
        
        % Store the altitude, coordinates, and coordinates copy in the cloudData cell array
       
        cloudData{cloudIndex2, 2} = coordinates;
        cloudData{cloudIndex2, 3} = coordinates;
        
        cloudIndex2 = cloudIndex2 + 1;  % Increment the cloud counter
    end
     
    % Assign the cloud data to the corresponding position in the polygons matrix
    polygons3d{leadTimeIndex, 1, nowcastMember} = leadTime;
    polygons3d{leadTimeIndex, 2, nowcastMember} = leadTimeInSeconds;
    polygons3d{leadTimeIndex, 3, nowcastMember} = cloudData;
end

save('polygons3d.mat', 'polygons3d');
end
