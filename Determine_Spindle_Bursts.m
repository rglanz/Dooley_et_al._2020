function Output = Determine_Spindle_Bursts(LFPValues, LFPTimes, Fs, MinLength)
% Output = Determine_Spindle_Bursts(LFPValues, LFPTimes, Fs, MinLength)
%
% Takes a raw LFP signal and both detects spindle bursts and calculates
% several spindle burst related stats.
%
% Dependencies              Spindle_Filter.m 
%                           Logical_Consecutive.m
%
% Inputs:                   LFPValues       A vector of the LFP waveform
%                                           values
%                           LFPTimes        A vector of LFP timepoints (in
%                                           s)
%                           Fs              The sampling rate of the LFP
%                                           waveform (in Hz)
%                           MinLength       The minimum length for a
%                                           spindle burst (in s)
% 
% Outputs                   Output          A structure with the following
%                                           fields:
%
%                               .Values         The filtered LFP waveform
%                               .Times          The times of the filtered
%                                               LFP waveform
%                               .Amplitude      The amplitude of the
%                                               resulting waveform
%                               .Phase          The phase of the resulting
%                                               waveform
%                               .Threshold      The threshold used on the
%                                               amplitude to determine a 
%                                               spindle burst.
%                               .SpindleLogical A logical that reports
%                                               whether each data point is
%                                               during a spindle burst
%                               .SpindleIndex   The same as spindle logical,
%                                               except instead of all
%                                               spindles being 1, they are
%                                               an integer of what number
%                                               spindle burst it is. Helps
%                                               for indexing particular
%                                               spindle bursts.
% 
% Given K spindle bursts detected
% .SB.StartTime   1xK vector   The start time of the spindle burst.
% .SB.EndTime     1xK vector   The end time of the spindle burst.
% .SB.Duration    1xK vector   The duration of the spindle burst.
% .SB.Amp         1xK cell     The amplitude of the spindle burst at each
%                                 datapoint.
% .SB.Phase       1xK cell     The phase of the spindle burst at each
%                                 datapoint.
% .SB.mAmp        1xK vector   The median amplitude of the spindle burst.
% .SB.sumPhase    1xK vector   The sum of all phase changes for the spindle
%                                 burst.
% .SB.nCycles     1xK vector   The number of cycles for each spindle burst.
%
% Contributed by Jimmy Dooley (james-c-dooley@uiowa.edu)
% Last updated 2.20.2020 by JD
%

%% Filter raw LFP
[fValues,fTimes] = Spindle_Filter(LFPValues,LFPTimes,Fs); % Filter the signal

%% Determine Amplitude, phase, and threshold on the filtered LFP
fValuesAmp = abs(hilbert(fValues)); % Amplitude
fValuesPhase = angle(hilbert(fValues)); % Phase
dPhase = diff(unwrap(fValuesPhase)); % Difference in phase
dPhase = [0; dPhase]; % Pad the vector
medAmp = nanmean(fValuesAmp);
sdAmp = nanstd(fValuesAmp);
Threshold = medAmp + 1.5*sdAmp;

%% Remove periods shorter than the minimum spindle burst length
fValuesAmpLogical = fValuesAmp > Threshold;
ThreshDuration = Logical_Consecutive(fValuesAmpLogical);
MinDuration = round(Fs*MinLength);
DurationLogical = ThreshDuration.ConsecutiveOutput < MinDuration;
fValuesAmpLogical(DurationLogical & fValuesAmpLogical) = 0;
ThreshDuration = Logical_Consecutive(fValuesAmpLogical);
DurationLogical = ThreshDuration.ConsecutiveOutput < MinDuration;
fValuesAmpLogical(DurationLogical & ~fValuesAmpLogical) = 1;
ThreshDuration = Logical_Consecutive(fValuesAmpLogical);

%% Get spindle burst index's and filtered LFP in output structure
Output.Values = fValues;
Output.Times = fTimes;
Output.Amplitude = fValuesAmp;
Output.Phase = fValuesPhase;
Output.Threshold = Threshold;
Output.SpindleLogical = fValuesAmpLogical;
Output.SpindleIndex = zeros(size(fValuesAmpLogical));

%% Determine indicies where spindle bursts start and stop
dfValuesAmpLogical = diff(fValuesAmpLogical); % where spindle bursts start and stop
SSI = find(dfValuesAmpLogical == 1); % Spindle Start Index
SEI = find(dfValuesAmpLogical == -1); % Spindle End Index
if SEI(1) < SSI(1) % If you start in the middle of a spindle burst
    SEI = SEI(2:end);
end
if SEI(end) < SSI(end) % If you end on a spindle burst
    SSI = SSI(1:end-1);
end

%% Get features of each spindle burst
nSpindles = min([length(SEI); length(SSI)]);
for iSpindle = 1:nSpindles
    Output.SpindleIndex(SSI(iSpindle):SEI(iSpindle)) = iSpindle; % Create string for easy spindleburst indexing
    Output.SB.StartTime(iSpindle) = SSI(iSpindle)/Fs; % Get spindleburst start time (in seconds)
    Output.SB.EndTime(iSpindle) = SEI(iSpindle)/Fs; % Get spindleburst end time (in seconds)
    Output.SB.Duration(iSpindle) = Output.SB.EndTime(iSpindle) - Output.SB.StartTime(iSpindle); % Get spindleburst duration
    Output.SB.Amp{iSpindle} = fValuesAmp(SSI(iSpindle):SEI(iSpindle)); % Get spindleburst amplitude throughout 
    Output.SB.Phase{iSpindle} = fValuesPhase(SSI(iSpindle):SEI(iSpindle)); % Get spindleburst phase throughout
    Output.SB.mAmp(iSpindle) = median(fValuesAmp(SSI(iSpindle):SEI(iSpindle))); % Get spindleburst median amplitude
    Output.SB.sumPhase(iSpindle) = sum(dPhase(SSI(iSpindle):SEI(iSpindle))); % Get the phase duration of the spindleburst
    Output.SB.nCycles(iSpindle) = Output.SB.sumPhase(iSpindle) / (2*pi); % Get the number of cycles of the spindleburst
end

end