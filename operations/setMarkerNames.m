function [argFunc, opFunc] = setMarkerNames
%setMarkerNames Adds markers names for subsequent use by addMarkers
%   function.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be markerNames
        prompt = {'Names of markers (separated by comma):'};
        dlg_title = 'Add marker names';
        num_lines = 1;
        defaultans = {'m1; m2; m3'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        markerNames = answer{1};
        if(isempty(markerNames))
            returnArgs = {};
        else
            returnArgs = {markerNames};
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be markerNames
        markerNames = args{1};
        opDataOut.markerNames = markerNames;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end