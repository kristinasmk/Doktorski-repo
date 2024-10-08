function [TS, indices, numACtrajectories] = sampling (Trajectories, currentWeatherScenario)
%This function randomly picks trajectory from TrafficArchive and assigns it
%to Traffic scenario

%Inputs: Trajectories - contains trajectory data
%        CurrentWeatherScenario 

%Outputs: indices - indices of trajectory position per aircraft
%         numACtrajectories - number of trajectories in traffic scenario
%--------------------------------------------------------------------------

TS ={}
indices = {}

for n = 1:numel(Trajectories)
weatherT = Trajectories(n).data(currentWeatherScenario,:,:);
weatherT_list = reshape(weatherT, [30,1]);
r = randperm(30);
sample_i = r(1);
sample_trajectory = weatherT_list{sample_i, 1};

%% Ovo æu otkomentirati kada provjerim što je s trajektorijama koje imaju NaN
% i = 1;
% while isnan(sample_trajectory) && i< numel(r)
%     i =i+1;
%     sample_i = r(i);
%     sample_trajectory = weatherT_list{sample_i,1};
% end

TS{n, 1} = sample_trajectory;
indices (n,1) = sample_i;
end

numACtrajectories = numel(TS);