function MovePeriods = Determine_Movement_Periods(Intensity, IntensitySmooth, TrailingMoveLength)
% MovePeriods = Determine_Movement_Periods(Intensity, IntensitySmooth, minMoveLength)
%
% Takes output from Video_Change_Detection.m and determines indices of 
% movement movement periods for each ROI.
%
% Inputs                Intensity           Output from
%                                           Video_Change_Detection.m
%
%                       IntensitySmooth     The time (in seconds) to smooth
%                                           the intensity vector for each
%                                           ROI
%
%                       TrailingMoveLength  The time added (in seconds)
%                                           following each movement period
%
%
% Outputs               MovePeriods         A structure with the following
%                                           fields:
%
%                           .Video          The name of the video analyzed
%                           .[ROI Name]     A field for each ROI in that
%                                           video
% 
% Within each ROI field, find the following fields
% .Values           The change in intensity for that ROI for each frame
% .Time             The time (in seconds) for each frame
% .sValues          The smoothed intensity value for that frame and ROI
% .Threshold        The theshold intensity value for movement
% .MovementPeriods  Logical vector of periods of movement (1) and no
%                      movement (0)
%
%
% Contributed by Jimmy Dooley (james-c-dooley@uiowa.edu)
% Last updated 2.20.2020 by JD
%

nVideos = length(Intensity);
for iVideo = 1:nVideos
    MovePeriods(iVideo).Video = Intensity(iVideo).name;
    nROI = length(Intensity(iVideo).ROI);
    for iROI = 1:nROI
        cROI = Intensity(iVideo).ROI(iROI).Label{:};
        MovePeriods(iVideo).(cROI).Values = Intensity(iVideo).ROI.IntensityChange;
        MovePeriods(iVideo).(cROI).Time = Intensity(iVideo).frameTimeStamps;
        FrameRate = 1/(MovePeriods(iVideo).(cROI).Time(2)-MovePeriods(iVideo).(cROI).Time(1));
        nFramesSmooth = round(IntensitySmooth*FrameRate);
        nFramesTrailingMove = round(TrailingMoveLength*FrameRate);
        MovePeriods(iVideo).(cROI).sValues = smooth(MovePeriods(iVideo).(cROI).Values,nFramesSmooth);
        sMoveMax = movmax(MovePeriods(iVideo).(cROI).sValues,[nFramesTrailingMove 0]);
        MovePeriods(iVideo).(cROI).Threshold = mean(sMoveMax);
        MovePeriods(iVideo).(cROI).MovementPeriods = sMoveMax > MovePeriods(iVideo).(cROI).Threshold;
    end
end

end