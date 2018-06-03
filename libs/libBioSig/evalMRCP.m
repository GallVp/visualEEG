function [ measureValues, measureNames, measureUnits, grandMRCPfiltered] = evalMRCP( usingEpochs, fs, timeBeforeEvent)
%evalMRCP Evaluates performance measures from a MRCP signal epochs
%   'usingEpochs'. fs is the sample-rate and 'timeBeforeEvent' is the epoch
%   length before events in seconds.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

%% Processing constants
MRCP_FREQ_CUTOFF                = 5;            % Hz
EEG_PN_WINDOW                   = [-1 1];       % In seconds wrt event
EEG_NOISE_WINDOW                = [-3 -2];      % In seconds wrt event
EEG_SIGNAL_WINDOW               = [-2 0];       % In seconds wrt event


%% Parameters
pnWindow = (EEG_PN_WINDOW + timeBeforeEvent) * fs;

grandMRCPfiltered = lowPassStream(mean(usingEpochs, 3), fs, MRCP_FREQ_CUTOFF);

%% Evaluate PN and PNT
[PN, PNT] = findpeaks(-grandMRCPfiltered(pnWindow(1)+1:pnWindow(2)), 'SortStr', 'descend', 'NPeaks', 1);
PN          = -PN;
PNT         = (PNT + pnWindow(1)) ./fs - timeBeforeEvent;
PNT         = PNT .* 1000;  % convert to ms.
%% Find signal and noise segments
EEG_SIGNAL_WINDOW(2) = EEG_SIGNAL_WINDOW(2) + PNT / 1000;
signalSegmentIndices = round((EEG_SIGNAL_WINDOW + timeBeforeEvent) * fs);
noiseSegmentIndices = round((EEG_NOISE_WINDOW + timeBeforeEvent) * fs);
signalSegmentEpochs = usingEpochs(signalSegmentIndices(1)+1:signalSegmentIndices(2), :, :);
noiseSegment = grandMRCPfiltered(noiseSegmentIndices(1)+1:noiseSegmentIndices(2));

%% Premovement noise
PMN     = rms(noiseSegment);
PMNpp   = max(noiseSegment) - min(noiseSegment);

%% SNR
SNR = 10 .* log10(abs(PN) ./ PMN);

%% CVerp
CV = zeros(size(signalSegmentEpochs, 3), 1);
for i=1:size(signalSegmentEpochs, 3)
    filteredEpoch = lowPassStream(signalSegmentEpochs(:,:, i), fs, MRCP_FREQ_CUTOFF);
    CV(i) = abs(std(filteredEpoch) / mean(filteredEpoch));
end

CVerp = mean(CV, 'omitnan');

%% Assign results
measureValues = [PN; PNT; PMN; PMNpp; CVerp; SNR];
measureNames = {'PN'; 'PNT'; 'PMN'   ; 'PMN' ; 'CV'  ; 'SNR'};
measureUnits = {'uV'; 'ms' ; 'uVrms' ; 'uVpp'; 'Var' ; 'dB' };
end