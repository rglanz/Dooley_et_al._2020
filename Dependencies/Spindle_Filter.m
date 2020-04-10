function [fx, fTimes] = Spindle_Filter(x, Times, Fs)
% [fx, fTimes] = Spindle_Filter(x, Times, Fs)
%
% Filters LFP data x in spindle burst frequencies and removes phase shift
% introduced by the filter.
%
% Input                 x               Waveform Values
%
%                       Times           Waveform Times
%
%                       Fs              Waveform sampling rate (Hz)
%
%
% Output                fx              Waveform values after filtering
%
%                       fTimes          Adjusted waveform times
%                                       (eliminating phase shift).
%
%
% Contributed by Jimmy Dooley (james-c-dooley@uiowa.edu)
% Last updated 2.20.2020 by JD
%

persistent Hd;

if isempty(Hd)
    Fstop1 = 8;        % First Stopband Frequency
    Fpass1 = 9;        % First Passband Frequency
    Fpass2 = 39;       % Second Passband Frequency
    Fstop2 = 40;       % Second Stopband Frequency
    Astop1 = 60;       % First Stopband Attenuation (dB)
    Apass  = 1;        % Passband Ripple (dB)
    Astop2 = 60;       % Second Stopband Attenuation (dB)
    
    h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, ...
        Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
    
    Hd = design(h, 'equiripple', ...
        'MinOrder', 'any');
    
    set(Hd,'PersistentMemory',true);
end

delay = round(length(Hd.States)/2); % Phase shift is equal to half the order of the filter
delayTime = round(delay/Fs,3);

y = filter(Hd,x);
fx = y(delay+1:end);
fTimes = Times(1:end-delay);

end