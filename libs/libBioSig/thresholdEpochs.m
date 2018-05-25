function [ markedEpochs ] = thresholdEpochs(epochs, ppThreshold, artefactWindow)
%thresholdEpochs Marks epochs with peak to peak thresholding.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

if nargin < 3
    artefactWindow = [0 size(epochs, 1)];
end

selectedData = epochs(artefactWindow(1)+1:artefactWindow(2),:, :);

thresholdData = max(selectedData) - min(selectedData) >= ppThreshold;

markedEpochs = sum(thresholdData, 1);
markedEpochs = sum(markedEpochs, 2);

markedEpochs = markedEpochs ~= 0;

markedEpochs = squeeze(markedEpochs);
end

