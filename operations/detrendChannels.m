function [argFunc, opFunc] = detrendChannels
%detrendChannels Detrends each channel.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be 'linear' or 'constant'.
        options = {'constant', 'linear'};
        [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','single',...
            'ListString', options, 'ListSize', [160 75]);
        returnArgs = options(s);
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be 'linear' or 'constant'
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                processedData(:, :, i) = detrend(opData.channelStream(:, :, i) , args{1});
            end
        else
            processedData = detrend(opData.channelStream, args{1});
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end