function [argFunc, opFunc] = removeCommonMode
%removeCommonMode Removes common mode from the channels
%
% Copyright (c) <2016> <Usman Rashid>
% Licensed under the MIT License. See License.txt in the project root for
% license information.

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
        M=eye(opData.numChannels)-1/opData.numChannels*ones(opData.numChannels);
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                processedData(:, :, i) = opData.channelStream(:, :, i) * M;
            end
        else
            processedData = opData.channelStream * M;
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function updateView(axH, opData)
    end
end