function [argFunc, opFunc] = excludeEpochs
%excludeEpochs Exclude marked epochs
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
        opDataOut.channelStream         = opData.channelStream(:,:, ~opData.epochExcludeStatus);
        opDataOut.numEpochs             = size(opDataOut.channelStream, 3);
        opDataOut.epochsRetained        = find(~opData.epochExcludeStatus);
        opDataOut.epochExcludeStatus    = zeros(opDataOut.numEpochs, 1);
        opDataOut.epochNum              = 1;
        % Remove custom updateView function
        opDataOut.updateView            = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end