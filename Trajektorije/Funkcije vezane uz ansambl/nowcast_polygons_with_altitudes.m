load('nowcast.mat')
safety_margin = nowcast.safety_margin;
lead_time = nowcast.lead_times;
nowcast_members = nowcast.nowcast_members;
reference_time = nowcast.reference_time;
geometries = nowcast.geometries;

polygons = struct('lead_time', [], 'nowcast_members', [], 'coordinates', []);

for i = 1:numel(geometries)
    lon = geometries(i).LON;
    lat = geometries(i).LAT;
    cth = geometries(i).CTH;
    
    nanMask1 = isnan(lon);
    nanMask2 = isnan(lat);
    nanMask3 = isnan(cth);
    
    startIndices1 = [1; find(nanMask1) + 1];
    endIndices1 = [find(nanMask1); numel(lon)];
    startIndices2 = [1; find(nanMask2) + 1];
    endIndices2 = [find(nanMask2); numel(lat)];
    startIndices3 = [1; find(nanMask3) + 1];
    endIndices3 = [find(nanMask3); numel(cth)];
    
    lonCells = arrayfun(@(start, finish) lon(start:finish), startIndices1, endIndices1, 'UniformOutput', false);
    latCells = arrayfun(@(start, finish) lat(start:finish), startIndices2, endIndices2, 'UniformOutput', false);
    cthCells = arrayfun(@(start, finish) cth(start:finish), startIndices3, endIndices3, 'UniformOutput', false);
    
    for j = 1:numel(lonCells)
        tempPolygon.lead_time = geometries(i).lead_time;
        tempPolygon.nowcast_members = geometries(i).nowcast_member;
        
        coordinates = [latCells{j}, lonCells{j}];
        coordinates = coordinates(~isnan(coordinates(:,1)), :);
        
        altitudes = cthCells{j};
        altitudes = altitudes(~isnan(altitudes));
        altitudes = [0, altitudes];  % Add 0 at the beginning of the altitude vector
        
        % Create a structure to hold coordinates and altitudes
        coord_alt = struct('coordinates', coordinates, 'altitudes', altitudes);
        
        % Assign the coord_alt structure to the coordinates field of tempPolygon
        tempPolygon.coordinates = coord_alt;
        
        % Append the tempPolygon to the polygons structure array
        polygons(end+1) = tempPolygon;
    end
end
polygons = polygons(2:end);

%ovaj dio koda pretvara naèin pisanja lead_time u sekunde od ponoæi
referenceTime = datetime(nowcast.reference_time, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
referenceTimeInSeconds = hour(referenceTime)*3600 + minute(referenceTime)*60 + second(referenceTime);

for i = 1:numel(polygons)
    leadTime = polygons(i).lead_time;
    leadTimeInSeconds = leadTime + referenceTimeInSeconds;
    polygons(i).lead_time = leadTimeInSeconds;
end
save('polygons.mat', 'polygons');
