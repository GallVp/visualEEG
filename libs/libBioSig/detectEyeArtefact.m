function [ eyeArtefactEpochs ] = detectEyeArtefact(epochs, ppThreshold, artefactWindow)
%detectEyeArtefact Takes eeg epochs and detects eye artefacts in each epoch
%   in the artefact window.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

if nargin < 3
    artefactWindow = [0 size(epochs, 1)];
end

selectedData = epochs(artefactWindow(1)+1:artefactWindow(2),:, :);

thresholdData = max(selectedData) - min(selectedData) >= ppThreshold;

eyeArtefactEpochs = sum(thresholdData, 1);
eyeArtefactEpochs = sum(eyeArtefactEpochs, 2);

eyeArtefactEpochs = eyeArtefactEpochs ~= 0;

eyeArtefactEpochs = squeeze(eyeArtefactEpochs);
end

