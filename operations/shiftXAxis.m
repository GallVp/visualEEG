function [argFunc, opFunc] = shiftXAxis
%shiftXAxis Shifts x axis by a constant. resultXAxis = currentXAxis -
%   constant.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be xShift
        prompt = {'Shift'};
        dlg_title = 'Shift x-axis';
        num_lines = 1;
        defaultans = {'0'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        xShift = str2num(answer{1});
        if(isempty(xShift))
            returnArgs = {};
        else
            if(isnan(xShift))
                returnArgs = {};
            else
                returnArgs = {xShift};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be xShift
        xShift = args{1};
        opDataOut.abscissa = opData.abscissa - xShift;
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
    end
end