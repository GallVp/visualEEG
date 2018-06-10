function [ measureValues, measureNames, measureUnits, grandMRCPfiltered] = evalMRCP( usingEpochs, fs, timeBeforeEvent)
%evalMRCP Evaluates performance measures from a MRCP signal epochs
%   'usingEpochs'. fs is the sample-rate and 'timeBeforeEvent' is the epoch
%   length before events in seconds.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

%% Processing constants
MRCP_FREQ_CUTOFF    = 5;            % Hz
EEG_PN_WINDOW       = [-1 1];       % In seconds wrt event
EEG_NOISE_WINDOW    = [-3 -2];      % In seconds wrt event
EEG_SIGNAL_WINDOW   = [-2 0];       % In seconds wrt event


%% Parameters
pnWindow            = (EEG_PN_WINDOW + timeBeforeEvent) * fs;
grandMRCPfiltered   = lowPassStream(mean(usingEpochs, 3), fs, MRCP_FREQ_CUTOFF);
%% Evaluate PN and PNT
[PN, PNT]           = findpeaks(-grandMRCPfiltered(pnWindow(1)+1:pnWindow(2)), 'SortStr', 'descend', 'NPeaks', 1);
PN                  = -PN;
PNT                 = (PNT + pnWindow(1)) ./fs - timeBeforeEvent;
PNT                 = PNT .* 1000;  % convert to ms.
%% Find signal and noise segments
noiseSegmentIndices = round((EEG_NOISE_WINDOW + timeBeforeEvent) * fs);
baselineSegment     = grandMRCPfiltered(noiseSegmentIndices(1)+1:noiseSegmentIndices(2));
%% Premovement noise
BLA                 = rms(baselineSegment);
%% SNR
SNR                 = 10 .* log10(abs(PN) ./ BLA);
%% Assign results
measureValues       = [PN ; PNT  ; BLA     ; SNR];
measureNames        = {'PN'; 'PNT'; 'BLA'   ; 'SNR'};
measureUnits        = {'uV'; 'ms' ; 'uVrms' ; 'dB' };
end