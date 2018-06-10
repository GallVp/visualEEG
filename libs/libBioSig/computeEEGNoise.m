function [ averagedNoise, channelEpochNoise ] = computeEEGNoise( epochs, noiseIndices)
%computeEEGNoise Computes rms noise in epochs and channels.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

numEpochs = size(epochs, 3);
numChannels = size(epochs, 2);
channelEpochNoise = zeros(1, numChannels, numEpochs);

for epochNum=1:numEpochs
    channelEpochNoise(1,:, epochNum) = rms(epochs(noiseIndices, :, epochNum));
end

averagedNoise = mean(mean(channelEpochNoise, 3, 'omitnan'), 2, 'omitnan');
end

