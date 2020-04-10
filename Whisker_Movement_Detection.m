function DLC = Whisker_Movement_Detection(DLC, varargin)
% DLC = Whisker_Movement_Detection(DLC...)
%
% Detects movements of the whiskers from DLC data.
%
%
% Inputs                DLC             Structure object created by
%                                       Whisker_DLC_Import
%
%                       Optional        'Name', Value
%
%                       Threshold       Value of threshold (in multiples of
%                                       standard deviation of the signal).
%                                       (Default is 2, used in Dooley et
%                                       al., 2020)
%
%                       TimeRange       Two-element vector specifying range
%                                       of times (0 to 1) to include for
%                                       thresholding. Useful if the
%                                       beginning or end of the data stream
%                                       contains noise. (Default is [0 0.2])
%
%
% Outputs               DLC             Structure with movement onset times
%                                       added
%
% Contributed by Jimmy Dooley (james-c-dooley@uiowa.edu) and Ryan Glanz
% (ryan-glanz@uiowa.edu)
% Last updated 4.8.2020 by RG
%

%% Parameters
Params = inputParser;
Params.addRequired('DLC', @(x) isstruct(x));
Params.addParameter('Threshold', 2, @isnumeric);
Params.addParameter('TimeRange', [0 0.2], @isnumeric);
Params.parse(DLC, varargin{:});

threshold = Params.Results.Threshold;
timeRange = Params.Results.TimeRange;
if numel(timeRange) ~= 2 || any(timeRange > 1) || any(timeRange < 0)
    error('Choose a valid time range.')
end

%% Set Threshold
nFrames = size(DLC(end).displacement, 1);
frameIndex = (0:nFrames) / nFrames; % Index of frame times from 0 to 1
[~, firstFrame] = min(abs(frameIndex - timeRange(1)));  % Find first frame number corresponding with timeRange
[~, lastFrame] = min(abs(frameIndex - timeRange(2)));   % Find last frame, as above

minPeak = threshold * std(DLC(end).displacement(firstFrame:lastFrame));

%% Event Detection
[~, DLC(end).movementOnset] = findpeaks(DLC(end).displacement, 'MinPeakProminence',...
    minPeak);

end
