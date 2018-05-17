function [ cleanedData, artefactPoints ] = removeImpulseArtefact( inputData, diagonisticPlot, dpTitle, cuttOff )
%removeImpulseArtefact Removes the impulses in inputData. Channels are
%   across columns. Impulses are defined as single isolated one sample
%   spikes above 'cuttOff' ~ 1500.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

if(nargin < 2)
    diagonisticPlot = 1;
    dpTitle = 'Diagnostic plot';
    cuttOff = 1500;
elseif(nargin < 3)
    dpTitle = 'Diagnostic plot';
    cuttOff = 1500;
elseif(nargin < 4)
    cuttOff = 1500;
end
NUM_CONSEC_EVENTS = 2;
eventsAreAt = inputData > cuttOff | inputData < -cuttOff;

% Ignore all those events which are not isolated single events
[moreThanOneConscEventsAt, ~] = consecEvents(eventsAreAt, NUM_CONSEC_EVENTS);
artefactPoints = eventsAreAt;
artefactPoints(moreThanOneConscEventsAt) = false;

artefactPointsL = circshift(artefactPoints, -1);
artefactPointsL(end) = false;

artefactPointsR = circshift(artefactPoints, 1);
artefactPointsR(1) = false;

cleanedData = inputData;

cleanedData(artefactPoints) = (cleanedData(artefactPointsL) + cleanedData(artefactPointsR)) / 2;


%% Do diagnostic plotting
if(diagonisticPlot && ~isempty(find(artefactPoints, 1)))
    numChannels = size(inputData, 2);
    if(numChannels > 1)
        [~, J] = find(artefactPoints);
        channelsWithArtefact = unique(J);
        numChannelsWithArtefact = length(channelsWithArtefact);
        for i = 1:numChannelsWithArtefact
            chanInd = channelsWithArtefact(i);
            figure
            plot(inputData(:, chanInd));
            hold on;
            plot(find(artefactPoints(:, chanInd)), inputData(artefactPoints(:, chanInd), chanInd), 'ro');
            plot(find(artefactPoints(:, chanInd)), cleanedData(artefactPoints(:, chanInd), chanInd), 'k*');
            xlabel('Sample No.');
            ylabel('Amplitude');
            title(sprintf('%s for channel no. %d', dpTitle, chanInd));
            hold off;
        end
    else
        figure
        plot(inputData);
        hold on;
        plot(find(artefactPoints), inputData(artefactPoints), 'ro');
        plot(find(artefactPoints), cleanedData(artefactPoints), 'k*');
        xlabel('Sample No.');
        ylabel('Amplitude');
        title(dpTitle);
        hold off;
    end
end
end

