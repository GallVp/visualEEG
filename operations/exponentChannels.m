function [argFunc, opFunc] = exponentChannels
%exponentChannels Applies the exponent (x ^ y) operation to each channel.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        prompt = {'Exponent:'};
        dlg_title = 'Exponentiation';
        num_lines = 1;
        defaultans = {'2'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        y = str2double(answer{1});
        if(isempty(y))
            returnArgs = {};
        else
            if(y <= 0 || isnan(y))
                returnArgs = {};
            else
                returnArgs = {y};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut   = opData;
        exponent    = args{1};
        opDataOut.channelStream = opData.channelStream .^ exponent;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function updateView(axH, opData)
    end
end