function [ evokedAndInduced, computedPower ] = computeEEGPower( epochs, fs)
%computeEEGPower Computes power in the four eeg
%   bands<delta, theta, alpha, beta> in each epoch of each channel. The
%   returned values for the four bands are the average from all epochs
%   of all channels.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

EEG_DELTA_RANGE                 = [0.05 3];
EEG_THETA_RANGE                 = [3 8];
EEG_ALPHA_RANGE                 = [8 12];
EEG_BETA_RANGE                  = [12 38];

numEpochs = size(epochs, 3);
numChannels = size(epochs, 2);
computedPower = zeros(4, numChannels, numEpochs);

for epochNum=1:numEpochs
    computedPower(1,:, epochNum) = bandpower(epochs(:,:, epochNum), fs, EEG_DELTA_RANGE);
    computedPower(2,:, epochNum) = bandpower(epochs(:,:, epochNum), fs, EEG_THETA_RANGE);
    computedPower(3,:, epochNum) = bandpower(epochs(:,:, epochNum), fs, EEG_ALPHA_RANGE);
    computedPower(4,:, epochNum) = bandpower(epochs(:,:, epochNum), fs, EEG_BETA_RANGE);
end

evokedAndInduced = mean(mean(computedPower, 3), 2);
end

