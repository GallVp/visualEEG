function [argFunc, opFunc] = loadEvents
%loadEvents Loads events variable from file.
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
        [s,~] = listdlg('PromptString','Select events variable:', 'SelectionMode','single',...
            'ListString', options);
        returnArgs = options(s);
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be the name of the events variable.
        eventsVariableName = args{1};
        opDataOut.events = opData.fileData.(eventsVariableName);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function updateView(axH, opData)
    end
end