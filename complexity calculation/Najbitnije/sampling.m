function [TS, indices, numACtrajectories] = sampling (Trajectories, currentWeatherScenario)
%This function randomly picks trajectory from TrafficArchive and assigns it
%to Traffic scenario

%Inputs: Trajectories - contains trajectory data
%        CurrentWeatherScenario 

%Outputs: indices - indices of trajectory position per aircraft
%         numACtrajectories - number of trajectories in traffic scenario
%--------------------------------------------------------------------------

persistent usedIndices; % Tracks used indices
persistent resetCount; % Tracks how many times we've reset the list

numWeatherScenarios = 15;
numAircraft = numel(Trajectories);

if isempty(usedIndices)
        usedIndices = cell(numAircraft, numWeatherScenarios);
        resetCount = zeros(numAircraft, numWeatherScenarios);
end
 
TS ={}
indices = {}

for n = 1:numAircraft
weatherT = Trajectories(n).data(currentWeatherScenario,:,:);
weatherT_list = reshape(weatherT, [30,1]);

 % If all trajectories have been used, reset the list
if numel(usedIndices{n, currentWeatherScenario}) >= 30
    usedIndices{n, currentWeatherScenario} = [];
    resetCount(n, currentWeatherScenario) = resetCount(n, currentWeatherScenario) +1; 
end

% Get a list of unused indices
availableIndices = setdiff(1:30, usedIndices{n, currentWeatherScenario});

r = randperm(numel(availableIndices));
sample_i = availableIndices(r(1));
sample_trajectory = weatherT_list{sample_i, 1};

usedIndices{n, currentWeatherScenario} = [usedIndices{n, currentWeatherScenario}, sample_i];

%% Ovo æu otkomentirati kada provjerim što je s trajektorijama koje imaju NaN
% i = 1;
% while isnan(sample_trajectory) && i< numel(r)
%     i =i+1;
%     sample_i = r(i);
%     sample_trajectory = weatherT_list{sample_i,1};
% end

TS{n, 1} = sample_trajectory;
indices {n,1} = sample_i;
end

numACtrajectories = numel(TS);