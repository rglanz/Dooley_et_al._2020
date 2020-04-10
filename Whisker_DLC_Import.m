function DLC = Whisker_DLC_Import(dlcPath)
% DLC = Whisker_DLC_Import(dlcPath)
%
% Imports DLC data (from .csv file) into a non-scalar structure array
%
%
% Inputs                dlcPath         Full path to .csv output from DLC
%                       
%
% Outputs               DLC             Structure containing whisker
%                                       position and displacement waveforms
%
% Contributed by Jimmy Dooley (james-c-dooley@uiowa.edu) and Ryan Glanz
% (ryan-glanz@uiowa.edu)
% Last updated 4.8.2020 by RG
%

%% Import DLC Data
importOptions = detectImportOptions(dlcPath, 'NumHeaderLines', 1);
csvData = readmatrix(dlcPath, importOptions);
csvHeaders = importOptions.SelectedVariableNames;

csvIndex = reshape(2:size(csvData,2), 3, (size(csvData,2)-1)/3);

DLC = struct('name', cell(1, size(csvIndex, 2)),...
    'position', cell(1, size(csvIndex, 2)));
for iColumn = 1:size(csvIndex, 2)
    DLC(iColumn).name = csvHeaders(csvIndex(2, iColumn));
    DLC(iColumn).position = csvData(:, csvIndex(2, iColumn));
end

%% Calculate Displacement
for iWhisker = 1:size(DLC, 2)
    cSmoothComponent = smooth(DLC(iWhisker).position, 10*100);  % Smooth position data, 10 s window
    DLC(iWhisker).displacement = abs(DLC(iWhisker).position - cSmoothComponent);    % Remove smoothing component 
end

%% Consolidate Whiskers
nWhiskers = size(DLC, 2);
DLC(nWhiskers+1).name = 'AllWhiskers';
DLC(nWhiskers+1).displacement = mean(horzcat(DLC.displacement), 2);

end

