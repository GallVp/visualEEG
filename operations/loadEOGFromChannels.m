function [argFunc, opFunc] = loadEOGFromChannels
%loadEOGFromChannels Loads eogData from channelData.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be a channel number corresponding to EOG.
        if(isempty(opData.channelNames))
            options = cellstr(num2str((1:opData.numChannels)'));
        else
            options = opData.channelNames;
        end
        [s,~] = listdlg('PromptString','Select eog channel:', 'SelectionMode','single',...
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
        % args{1} should be a channel number corresponding to EOG.
        channelNum = args{1};
        opDataOut.eogChannel    = opData.channelStream(:, channelNum, :);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end