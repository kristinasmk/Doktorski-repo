% Predefine the variable names to load each dataset
structNames = {'TA1', 'TA2', 'TA3', 'TA4', 'TA5', 'TA6', 'TA7', 'TA8', 'TA9', 'TA10', 'TA11'};

% Loop to load each dataset
for i = 1:length(structNames)
    % Construct the file name dynamically (e.g., 'TA1.mat', 'TA2.mat', etc.)
    fileName = sprintf('%s.mat', structNames{i});
    
    % Load the structure from the file
    loadedData = load(fileName);
    
    assignin('base', structNames{i}, loadedData.(structNames{i}));
    
end

% Initialize empty struct array for merged data
mergedData = struct('data', {}, 'tDif', {}, 'name', {});

% List of all structure names
structNames = {'TA1', 'TA2', 'TA3', 'TA4', 'TA5', 'TA6', 'TA7', 'TA8', 'TA9', 'TA10', 'TA11'};

% Initialize a counter for the merged data index
currentIndex = 1;

% Loop through each structure and concatenate data
for i = 1:length(structNames)
    % Dynamically access each structure
    currentStruct = eval(structNames{i});
    
    % Check if the structure is an array (non-scalar)
    if length(currentStruct) > 1
        % Loop through each element in the structure array
        for k = 1:length(currentStruct)
            % Append each field to mergedData struct
            mergedData(currentIndex).data = currentStruct(k).data;  % Assign data
            mergedData(currentIndex).tDif = currentStruct(k).tDif;  % Assign tDif
            mergedData(currentIndex).name = currentStruct(k).name;   % Assign name
            currentIndex = currentIndex + 1;  % Increment index
        end
    else
        % If currentStruct is a scalar structure
        mergedData(currentIndex).data = currentStruct.data;  % Assign data
        mergedData(currentIndex).tDif = currentStruct.tDif;  % Assign tDif
        mergedData(currentIndex).name = currentStruct.name;   % Assign name
        currentIndex = currentIndex + 1;  % Increment index
    end
end

% Remove empty rows based on the fields in mergedData
nonEmptyIdx = ~cellfun(@isempty, {mergedData.name}) & ...
              ~cellfun(@isempty, {mergedData.data}) & ...
              ~cellfun(@isempty, {mergedData.tDif});  % Check for non-empty entries in all fields

% Keep only the non-empty entries
mergedData = mergedData(nonEmptyIdx);
nowcast1 = mergedData;
save nowcast1;