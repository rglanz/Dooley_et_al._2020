function Intensity = Video_Change_Detection(folderPath, varargin)
% Intensity = Video_Change_Detection(folderPath...)
%
% Computes a continuous time-series of frame-by-frame changes in pixel
% intensity within a video. User can select multiple ROIs for analysis. A
% modifiable threshold of minimum intensity change is used to eliminate
% stereotypical artifacts from small, frequent changes in pixel intensity
% across frames.
%
% ********PLEASE NOTE********
% The intensity time-series correlates with, but does not directly measure
% movement amplitude. Small movements may produce large intensity changes
% due to incongruent changes in lighting.
% ***************************
%
% Dependencies                      Video_File_Search.m
%                                   ROI_Selector.m
%
% Inputs        folderPath          Full path to folder containing video(s)
%
%               Optional            ('Name', Value)
%
%               Threshold           Threshold for stereotypical artifact
%                                   rejection (0 to 1; default is 0.05)
%
%               WriteCSV            Write output as CSV ('True' or 'False';
%                                   default is 'True')
%
%
% Outputs       Intensity           Structure containing time index and
%                                   intensity time-series
%
% Contributed by Jimmy Dooley (james-dooley@uiowa.edu) and Ryan Glanz
% (ryan-glanz@uiowa.edu)
% Last updated 3.4.20 by RG
%

%% Parameters
Params = inputParser;
Params.addRequired('folderPath', @(x) ischar(x) | isstring(x));
Params.addParameter('Threshold', 0.05, @isnumeric);
Params.addParameter('WriteCSV', 'True', @ischar);
Params.parse(folderPath, varargin{:});

threshold = Params.Results.Threshold;
if threshold < 0 || threshold > 1
    error('Select a threshold between 0 and 1.')
end
writeCSV = Params.Results.WriteCSV;

%% Verify Version (2018b or later)
matlabVersion = version('-release');
if str2double(matlabVersion(1:end-1)) <= 2018 && strcmp(matlabVersion(end), 'a')
    error('Upgrade to 2018b or above to run this script.')
end

%% Select Video(s)
VideoIndex = Video_File_Search(folderPath);
videoIdentifiers = arrayfun(@(x) strcat(char(x.name), " (", char(x.codec), ", ",...
    num2str(x.duration), " s)"), VideoIndex, 'UniformOutput', false);
videoIDs = listdlg('ListString', videoIdentifiers, 'ListSize', [300 500]);

%% Select ROI(s)
ROIData = struct('name', cell(1, length(videoIDs)), 'data',...
    cell(1, length(videoIDs)));
for iVideo = 1:length(videoIDs)
    currentVideoObject = VideoReader(fullfile(VideoIndex(videoIDs(iVideo)).path,...
        VideoIndex(videoIDs(iVideo)).name));
    
    ROIData(iVideo).name = VideoIndex(videoIDs(iVideo)).name;
    
    currentROIData = ROI_Selector(currentVideoObject);
    ROIData(iVideo).data = currentROIData(~cellfun(@isempty,...
        {currentROIData.Label}));
end

%% Change Detection
Intensity = struct('name', cell(1, length(videoIDs)), 'frameTimeStamps',...
    cell(1, length(videoIDs)));
for iVideo = 1:length(videoIDs)
    %% Display File Progress
    fileStartTime = now;
    disp(strcat("Reading file ", num2str(iVideo), " of ", num2str(length(videoIDs)), " (",...
        VideoIndex(videoIDs(iVideo)).name, "), started at ", datestr(fileStartTime, 'HH:MM AM'), "."));
    
    %% Video Time Stamps
    currentVideoObject = VideoReader(fullfile(VideoIndex(videoIDs(iVideo)).path,...
        VideoIndex(videoIDs(iVideo)).name)); % Import video for frame times
    videoDuration = currentVideoObject.Duration;
    frameRate = currentVideoObject.FrameRate;
    
    Intensity(iVideo).name = VideoIndex(videoIDs(iVideo)).name;
    Intensity(iVideo).frameTimeStamps = 1/frameRate : 1/frameRate : videoDuration;
    
    %% GPU Operations
    currentVideoObject = vision.VideoFileReader(fullfile(VideoIndex(videoIDs(iVideo)).path,...
        VideoIndex(videoIDs(iVideo)).name)); % Import video for analysis (GPU)
    
    frameIntensityChange = zeros(length(ROIData(iVideo).data), length(Intensity(iVideo).frameTimeStamps), 'single');
    currentFrameNumber = 1;
    while ~isDone(currentVideoObject)
        currentFrame = gpuArray(rgb2gray(currentVideoObject()));
        
        for iROI = 1:length(ROIData(iVideo).data)
            if currentFrameNumber > 1
                previousROI{iROI} = currentROI{iROI};
            end
            
            currentROI{iROI} = currentFrame(floor(ROIData(iVideo).data(iROI).Position(2)):...
                floor(ROIData(iVideo).data(iROI).Position(2))+ceil(ROIData(iVideo).data(iROI).Position(4)),...
                floor(ROIData(iVideo).data(iROI).Position(1)):...
                floor(ROIData(iVideo).data(iROI).Position(1))+ceil(ROIData(iVideo).data(iROI).Position(3))); % Extract the ROI values
            
            if currentFrameNumber > 1
                currentChange{iROI} = abs(currentROI{iROI}-previousROI{iROI});
                currentChange{iROI}(currentChange{iROI} < threshold) = 0;    % All pixel changes less than threshold are discarded
                frameIntensityChange(iROI, currentFrameNumber) = sum(sum(gather(currentChange{iROI}))); % Sum the area of interest so it's one value
            elseif currentFrameNumber == 1
                frameIntensityChange(iROI, currentFrameNumber) = 0;
            end
        end
        
        %% Update Progress
        percentComplete = round(length(Intensity(iVideo).frameTimeStamps)/10);
        if mod(currentFrameNumber + 1, percentComplete) == 1
            disp(strcat(num2str(100*round(currentFrameNumber/length(Intensity(iVideo).frameTimeStamps), 1)),...
                "% completed. Elapsed: ", datestr(now-fileStartTime, 'HH:MM:SS'), "."))
        end
        
        currentFrameNumber = currentFrameNumber + 1;    %Update frame number
        
    end
    
    %% Assign Output to Structure
    Intensity(iVideo).ROI = ROIData(iVideo).data;
    for iROI = 1:length(Intensity(iVideo).ROI)
        Intensity(iVideo).ROI(iROI).IntensityChange = frameIntensityChange(iROI, :);
    end
    
    %% Write CSV
    if strcmp(writeCSV, 'True')
        if length(Intensity(iVideo).frameTimeStamps) == length(Intensity(iVideo).ROI(1).IntensityChange)
            tableNames{1} = 'Time';
            tableData(:, 1) = Intensity(iVideo).frameTimeStamps;
            for iROI = 1:length(Intensity(iVideo).ROI)
                tableNames{iROI + 1} = Intensity(iVideo).ROI(iROI).Label{1};
                tableData(:, iROI + 1) = Intensity(iVideo).ROI(iROI).IntensityChange';
            end
            
            tableNames = matlab.lang.makeValidName(tableNames); % Removes invalid characters
            csvTable = array2table(tableData, 'VariableNames', tableNames); % Write data to table for export
            writetable(csvTable, strcat(VideoIndex(videoIDs(iVideo)).path, "\VCD_",...
                VideoIndex(videoIDs(iVideo)).name, ".csv"))  % Export table to CSV
            disp(strcat("PM_", VideoIndex(videoIDs(iVideo)).name, ".csv written!"))
        else
            disp("CSV skipped! Timestamps do not align with video frames.")
        end
    end
end

end
