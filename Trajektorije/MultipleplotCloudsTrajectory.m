clear
% Više trajektorija na jednom plotu
% Adjust this each time as needed
load 'C:\Users\ksamardzic\Documents\GitHub\Doktorski-repo\Trajektorije\nfz_cell.mat';
load 'E:\Doktorski-repo\nowcast\nowcast.mat';
load 'D:\Matlab\WS2\nowcast2.mat'; % Load the WS file to be plotted
load 'C:\Users\ksamardzic\Documents\GitHub\Doktorski-repo\Trajektorije\Bitni podaci koji se loadaju\polygons3d.mat';

latlim = [35 55];
lonlim = [0 25];
NumOfSafetyMargins = 3;
NumOfTOTimes = 10;

colormap(jet(numel(nowcast.nowcast_members)));

load coastlines;

numLeadTimes = size(nfz_cell, 1);

trajectoryMembers = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34]; % Members to include

for nowcastMember = 2 % Adjust for your specific use case
    for safetyMargin = 3 % Adjust for your specific use case
        for takeoffTime = 1 % Adjust for your specific use case
            figure
            ax = worldmap(latlim, lonlim);
            geoshow(coastlat, coastlon, 'Color', 'k');

            colorMapTrajectories = lines(length(trajectoryMembers)); % Unique colors for trajectories

            for leadTime = 1:numLeadTimes
                delete(findobj(ax, 'Type', 'patch'));
                
                Clouddata = polygons3d{leadTime, 3, nowcastMember, safetyMargin};
                
                % Plot cloud data
                for i = 1:size(Clouddata, 1)
                    cloudLon = Clouddata{i, 2}(:,2);
                    cloudLat = Clouddata{i, 2}(:,1);
                    Revolution = 27900 + leadTime * 300;

                    geoshow(coastlat, coastlon, 'Color', 'k');
                    geoshow(cloudLat, cloudLon, 'DisplayType', 'polygon', 'FaceColor', [0.8 0.8 0.8]); % Light gray for cloud
                    hold on;
                end

                % Plot each trajectory sequentially with a unique color
                for memberIdx = 1:length(trajectoryMembers)
                    trajectory = nowcast2(trajectoryMembers(memberIdx)).data{safetyMargin, takeoffTime};

                    indices = find(trajectory(:, 21) >= Revolution - 300 & trajectory(:, 21) < Revolution);
                    if ~isempty(indices)
                        partialTrajectory = trajectory(indices, :);
                        plotm(partialTrajectory(:, 2), partialTrajectory(:, 1), ...
                              'Color', colorMapTrajectories(memberIdx, :), 'LineWidth', 2);
                    end
                end
                
                % Update the title with the current lead time
                title(sprintf('Lead Time: %d, Safety Margin: %d, Takeoff Time: %d', leadTime, safetyMargin, takeoffTime));
                pause(0.5); % Pause for visualization (optional)
            end
        end
    end
end
