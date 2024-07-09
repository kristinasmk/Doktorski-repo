% creation of the map of all clouds that occur within simulation time
%checking if initial flight planned route crosses any cloud polygon
%returns the value 0 if clouds are not crossed and value 1 if they are

function [allClouddata, intersected, intersection_points] = crossing_check (Clouddata, AstarGrid, waypoints,nowcastMember)

CurrentCloudData = Clouddata(:, :, nowcastMember, 3);
allClouddata = {};

for cpos = 1: length(CurrentCloudData)
    Data = CurrentCloudData{cpos, 3};
    
    allClouddata = [allClouddata; Data];
end

[CloudsAll, cloudMap, CloudAlt,cloudMap3D] = cloudMerge_svrljanje (allClouddata,AstarGrid);

%dio koda gdje se gleda sijeku li se ruta i bilo koji oblak koji je
%deifiniran unutar CloudsAll

waypoint_x = [waypoints.x];
waypoint_y = [waypoints.y];
intersected = 0;
intersection_points = [];

nan_indices = find(isnan(CloudsAll(:, 1)));
start_idx = 1;
for i = 1:length(nan_indices) + 1
    if i <= length(nan_indices)
        end_idx = nan_indices(i) - 1;
    else
        end_idx = length(CloudsAll);
    end
    
    % Extract polygon points
    poly_x = CloudsAll(start_idx:end_idx, 2);
    poly_y = CloudsAll(start_idx:end_idx, 1);
    
    % Check if the route intersects with the polygon
    [xi, yi] = polyxpoly(waypoint_x, waypoint_y, poly_x, poly_y);
    
    if ~isempty(xi) && ~isempty(yi)
        intersected = 1;
        intersection_points = [intersection_points; xi, yi];
        break;
    end
    
    % Update the start index for the next polygon
    if i <= length(nan_indices)
        start_idx = nan_indices(i) + 1;
    end
end

end