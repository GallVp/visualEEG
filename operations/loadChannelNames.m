function [argFunc, opFunc] = loadChannelNames
%loadChannelNames Loads channel names variable from file.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be the name of the events variable.
        options = opData.fileVariableNames;
        [s,~] = listdlg('PromptString','Select channel names variable:', 'SelectionMode','single',...
            'ListString', options);
        returnArgs = options(s);
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be the name of the events variable.
        channelNamesVariableName = args{1};
        opDataOut.channelNames = opData.fileData.(channelNamesVariableName);
        
        opDataOut.legendInfo = opDataOut.channelNames;
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end