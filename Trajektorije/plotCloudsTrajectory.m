%jedan plot po safety margini
load 'C:\Matlab\nfz_cell.mat';
load 'C:\Matlab\USE\nowcast\nowcast.mat';
load 'C:\Matlab\TrafficArchive.mat';
load 'C:\Matlab\polygons3d.mat';

latlim = [35 55];
lonlim = [0 25];
NumOfSafetyMargins = 3;

colormap(jet(numel(nowcast.nowcast_members)));

load coastlines;

numLeadTimes = size(nfz_cell, 1);

for nowcastMember =1:size(nfz_cell,2)
    for safetyMargin = 1:NumOfSafetyMargins
        figure
    ax = worldmap(latlim, lonlim);
    geoshow(coastlat, coastlon, 'Color', 'k');

    color = colormap(ax);
    color = color(nowcastMember, :);
    
    trajectory = TrafficArchive(84).data{nowcastMember, safetyMargin};
    trajectoryColor = color;
    
    for leadTime = 1:numLeadTimes
        Clouddata = polygons3d{leadTime, 3, nowcastMember, safetyMargin};
        
        for i = 1: size(polygons3d{leadTime, 3, nowcastMember, safetyMargin},1)
            
        %cloud data for the current nowcast member and lead time
        cloudLon = Clouddata{i, 2}(:,2);
        cloudLat = Clouddata{i, 2}(:,1);
        Revolution = 27900 + leadTime*300;
              
        % ax = worldmap(latlim, lonlim);
        geoshow(coastlat, coastlon, 'Color', 'k');
        
        geoshow(cloudLat, cloudLon, 'DisplayType', 'polygon', 'FaceColor', color);
        hold on;
        end
        indices = find(trajectory(:, 21) >= Revolution - 299 & trajectory(:, 21) <= Revolution + 299);
     if ~isempty(indices)
            partialTrajectory = trajectory(indices, :);
            plotm(partialTrajectory(:, 2), partialTrajectory(:, 1), 'Color', trajectoryColor, 'LineWidth', 2);
     end
    title(sprintf('Lead Time: %d', leadTime));
    end
    end
end
