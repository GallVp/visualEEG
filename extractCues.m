function [ cues ] = extractCues( emgData, channNum )

% Copyright (c) <2016> <Usman Rashid>
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of
% the License, or  (at your option)  any later version.  See the
% file LICENSE included with this distribution for more information.

subjects = emgData.listSubjects;
sessions = emgData.listSessions;

cues = [];

for i = 1:length(subjects)
    for j = 1:length(sessions)
        emgData.loadData(subjects(i), sessions(j));
        processedData = emgData.sstData;
        
        [P, nT] = eegOperations.shapeProcessing(processedData);
        processedData = detrend(P, 'constant');
        processedData = abs(processedData);
        processedData = eegOperations.shapeSst(processedData, nT);
        
        numEpochs = size(processedData, 3);
        numChannels = size(processedData, 2);
        numSamples = size(processedData, 1);
        numStds = 3;
        for k=1:numEpochs
            for l=1:numChannels
                dataStd = std(processedData(:,l, k));
                processedData(:,l, k) = processedData(:,l, k) > dataStd * numStds;
            end
        end
        
        thresh = 1;
        peakNumber = 1;
        
        processingData = processedData;
        processedData = zeros(size(processingData));
        indices = zeros(numEpochs ,1);
        
        for k=1:numEpochs
            for l=1:numChannels
                pn = 0;
                for m=1:numSamples
                    if(processingData(m,l,k) >= thresh)
                        pn = pn +1;
                        if(peakNumber == 0)
                            processedData(m,l,k) = 1;
                            continue;
                        elseif(peakNumber == pn)
                            processedData(m,l,k) = 1;
                            if(l==channNum)
                                indices(k, 1) = m;
                            end
                            break;
                        else
                            continue;
                        end
                    else
                        continue;
                    end
                end
            end
        end
        cues = [cues; {subjects(i), sessions(j), indices./emgData.dataRate}];
    end
end
end