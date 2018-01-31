function [ epochs ] = epochData(data, epochEventIndices, samplesBeforeEvent, samplesAfterEvent)
%epochData Takes multichannel data and epochs it using events and [before
% after] time information. Implementation is first and last epoch short
% length safe.
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.

epochLength = samplesBeforeEvent + samplesAfterEvent;
numChannels = size(data, 2);
dataLength = size(data, 1);
epochs = zeros(epochLength, numChannels, length(epochEventIndices));

for i = 2:(length(epochEventIndices) - 1)
    selectedIndices = epochEventIndices(i) - samplesBeforeEvent + 1:epochEventIndices(i) + samplesAfterEvent;
    eData = data(selectedIndices, :);
    epochs(:, :, i) = eData;
end
% For first epoch
selectedIndices = epochEventIndices(1) - samplesBeforeEvent + 1:epochEventIndices(1) + samplesAfterEvent;
selectedIndices(selectedIndices < 1) = [];
eData = data(selectedIndices, :);
if(size(eData, 1) ~= epochLength)
    gapFil = zeros(epochLength - size(eData, 1), numChannels);
    epochs(:, :, 1) = [gapFil; eData];
else
    epochs(:, :, 1) = eData;
end
% For last epoch
selectedIndices = epochEventIndices(end) - samplesBeforeEvent + 1:epochEventIndices(end) + samplesAfterEvent;
selectedIndices(selectedIndices > dataLength) = [];
eData = data(selectedIndices, :);
if(size(eData, 1) ~= epochLength)
    gapFil = zeros(epochLength - size(eData, 1), numChannels);
    epochs(:, :, end) = [eData;gapFil];
else
    epochs(:, :, end) = eData;
end
end

