function [ measureValues, measureNames, measureUnits, filteredGA] = evalMRCP( usingGASignal, fs, timeBeforeEvent)
%evalMRCP Evaluates performance measures from a grand average MRCP signal
%   'usingGASignal' assumed to be band passed filtered in [0.05 40] Hz
%   range. fs is the sample-rate and 'timeBeforeEvent' is the epoch length
%   before events in seconds.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

%% Processing constants
MRCP_FREQ_RANGE                 = [0.05 5];
EEG_PN_WINDOW                   = [-1 1];       % In seconds wrt event
EEG_NOISE_WINDOW                = [-3 -2];      % In seconds wrt event
EEG_SIGNAL_WINDOW               = [-2 0];       % In seconds wrt event


%% Parameters
pnWindow = (EEG_PN_WINDOW + timeBeforeEvent) * fs;

%% MRCP_FEAT Filtered Data
filteredGA = lowPassStream(usingGASignal, fs, MRCP_FREQ_RANGE(2));

%% Evaluate PN and PNT
[PN, PNT] = findpeaks(-filteredGA(pnWindow(1)+1:pnWindow(2)), 'SortStr', 'descend', 'NPeaks', 1);
PN          = -PN;
PNT         = (PNT + pnWindow(1)) ./fs - timeBeforeEvent;
PNT         = PNT .* 1000;  % convert to ms.
%% Find signal and noise segments
EEG_SIGNAL_WINDOW(2) = EEG_SIGNAL_WINDOW(2) + PNT / 1000;
signalSegmentIndices = round((EEG_SIGNAL_WINDOW + timeBeforeEvent) * fs);
noiseSegmentIndices = round((EEG_NOISE_WINDOW + timeBeforeEvent) * fs);
signalSegment = filteredGA(signalSegmentIndices(1)+1:signalSegmentIndices(2));
noiseSegment = filteredGA(noiseSegmentIndices(1)+1:noiseSegmentIndices(2));

%% Premovement noise
PMN = rms(noiseSegment);

%% Signal CV
CV = abs(std(signalSegment) ./ mean(signalSegment)) .* 100;

%% SNR
SNR = 10 .* log10(abs(PN) ./ PMN);

%% Assign results
measureValues = [PN; PNT; PMN; CV; SNR];
measureNames = {'PN'; 'PNT'; 'PMN'   ; 'CV'; 'SNR'};
measureUnits = {'uV'; 'ms' ; 'uVrms' ; '%' ; 'dB' };
end