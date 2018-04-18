function [argFunc, opFunc] = channelMean
%channelMean Finds mean across channels
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % No argument required.
        returnArgs = {'N.R.'};
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % No argument required.
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(sz(1), 1, sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = mean(opData.channelStream(:, :, i), 2);
            end
        else
            processedData = mean(opData.channelStream, 2);
        end
        opDataOut.channelStream = processedData;
        opDataOut.channelNames = {'Mean Channel'};
        opDataOut.numChannels = size(opDataOut.channelStream, 2);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end