function [argFunc, opFunc] = channelSelect
%channelSelect Select channels from a list
%
% Copyright (c) <2016> <Usman Rashid>
% Licensed under the MIT License. See License.txt in the project root for
% license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be a vector with channel indices
        if(isempty(opData.channelNames))
            options = cellstr(num2str((1:opData.numChannels)'));
        else
            options = opData.channelNames;
        end
        [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','multiple',...
            'ListString', options, 'ListSize', [160 150]);
        if(isempty(s))
            returnArgs = {};
            return;
        end
        if(~isempty(opData.channelNames))
            returnArgs = {strcmpIND(opData.channelNames, options(s))};
        else
            returnArgs = {cellfun(@str2double, options(s))};
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be a vector with channel indices
        channelNums = args{1};
        opDataOut.channelStream = opData.channelStream(:, channelNums, :);
        opDataOut.numChannels = size(opDataOut.channelStream, 2);
        if(~isempty(opDataOut.channelNames))
            opDataOut.channelNames = opData.channelNames(channelNums);
        end
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function updateView(axH, opData)
    end
end