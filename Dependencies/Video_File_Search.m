function VideoIndex = Video_File_Search(folderPath)
% VideoIndex = Video_File_Search(folderPath)
%
% Creates an index of all videos in a folder (option to include
% subfolders).
%
% Dependencies                                      requires ffmpeg to
%                                                   obtain summary
%                                                   information
%
%
% Input                     folderPath              full path to folder
%                                                   containing videos or
%                                                   subfolder containing
%                                                   videos
%
% Output                    VideoIndex              index of video names,
%                                                   file paths, and summary
%                                                   information
%
%
% Contributed by Ryan Glanz (ryan-glanz@uiowa.edu)
% Last updated 3.4.20 by RG
%

%% Check for FFMPEG
ffmpegError = system('ffmpeg -version > NUL');
if ffmpegError
    warning('FFmpeg is not installed. Video information cannot be collected.')
end

%% Subfolder Selection Dialog
subfolderDecision = questdlg('Search for videos in subfolders?', 'Subfolders',...
    'Yes', 'No', 'No');
if strcmp(subfolderDecision, 'Yes')
    videoDirectory = dir(fullfile(folderPath, '**\*.avi'));    % All .avis in folderPath and its subfolders
elseif strcmp(subfolderDecision, 'No')
    videoDirectory = dir(fullfile(folderPath, '*.avi'));   % All .avis in folderPath
end

%% Video Index
VideoIndex = struct('path', cell(1, length(videoDirectory)),...
    'name', cell(1, length(videoDirectory)), 'codec', cell(1, length(videoDirectory)),...
    'duration', cell(1, length(videoDirectory))); % Pre-allocate VideoIndex
[VideoIndex(:).path] = videoDirectory(:).folder;
[VideoIndex(:).name] = videoDirectory(:).name;

%% Video Information
if ffmpegError == 0
    for iVideo = 1:length(VideoIndex)
        checkCodec = strcat("ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 ",...
            '"', fullfile(VideoIndex(iVideo).path, VideoIndex(iVideo).name), '"');
        checkDuration = strcat("ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ",...
            '"', fullfile(VideoIndex(iVideo).path, VideoIndex(iVideo).name), '"');
        
        [~, currentCodec] = system(checkCodec);
        [~, currentDuration] = system(checkDuration);
        
        VideoIndex(iVideo).codec = currentCodec(1:end-1);
        VideoIndex(iVideo).duration = str2double(currentDuration);
    end
end
    
end

