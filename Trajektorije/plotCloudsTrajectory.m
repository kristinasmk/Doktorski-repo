clear
%jedan plot po safety margini
%ovo treba izmjeniti svaki pu
load 'C:\Users\ksamardzic\Documents\GitHub\Doktorski-repo\Trajektorije\nfz_cell.mat';
load 'E:\Doktorski-repo\nowcast\nowcast.mat';
load 'D:\Matlab\WS1\nowcast1.mat'; %dodati onaj WS koji želim plotat
load 'C:\Users\ksamardzic\Documents\GitHub\Doktorski-repo\Trajektorije\Bitni podaci koji se loadaju\polygons3d.mat';

latlim = [35 55];
lonlim = [0 25];
NumOfSafetyMargins = 3;
NumOfTOTimes = 10;

colormap(jet(numel(nowcast.nowcast_members)));

load coastlines;

numLeadTimes = size(nfz_cell, 1);

trajectoryColor =[0, 0, 0];

for nowcastMember = 1 %1:size(nfz_cell,2)
    for safetyMargin = 3% 1:NumOfSafetyMargins
        for takeoffTime = 1% 1: NumOfTOTimes
        figure
    ax = worldmap(latlim, lonlim);
    geoshow(coastlat, coastlon, 'Color', 'k');

    color = colormap(ax);
    cloudcolor = color(nowcastMember, :);
    
    trajectory = nowcast1(363).data{safetyMargin, takeoffTime}; %staviti onaj koji želim plotat
   
    
    for leadTime = 1:numLeadTimes
        delete(findobj(ax, 'Type', 'patch'));
        
        Clouddata = polygons3d{leadTime, 3, nowcastMember, safetyMargin};
        
        for i = 1: size(polygons3d{leadTime, 3, nowcastMember, safetyMargin},1)
            
        %cloud data for the current nowcast member and lead time
        cloudLon = Clouddata{i, 2}(:,2);
        cloudLat = Clouddata{i, 2}(:,1);
        Revolution = 27900 + leadTime*300;
              
        % ax = worldmap(latlim, lonlim);
        geoshow(coastlat, coastlon, 'Color', 'k');
        
        geoshow(cloudLat, cloudLon, 'DisplayType', 'polygon', 'FaceColor', cloudcolor);
        hold on;
        end
        indices = find(trajectory(:, 21) >= Revolution - 300 & trajectory(:, 21) < Revolution-1);
     if ~isempty(indices)
            partialTrajectory = trajectory(indices, :);
            plotm(partialTrajectory(:, 2), partialTrajectory(:, 1), 'Color', trajectoryColor, 'LineWidth', 2);
     end
    title(sprintf('Lead Time: %d', leadTime));
    end
        end
    end
end
