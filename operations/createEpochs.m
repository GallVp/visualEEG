function [argFunc, opFunc] = createEpochs
%createEpochs Creates epochs with given intervals
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        
        if(isempty(opData.events))
            h = errordlg(sprintf('Operation only applicable to\ndata with events.'),...
                'createEpochs', 'modal');
            uiwait(h);
            returnArgs = {};
            return;
        end
        
        % args{1} should be [timeBefore timeAfter]
        if(opData.numEpochs > 1)
            returnArgs = {};
        else
            prompt = {'Epoch window [timeBefore timeAfter]:'};
            dlg_title = 'Epochs';
            num_lines = 1;
            defaultans = {'[3 3]'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            if(isempty(answer))
                returnArgs = {};
                return;
            end
            wn = str2num(answer{1});
            if(isempty(wn))
                returnArgs = {};
            else
                if(length(wn) ~= 2)
                    returnArgs = {};
                    return;
                end
                returnArgs = {wn};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be [timeBefore timeAfter]
        wn = round(args{1} .* opData.fs);
        opDataOut.channelStream = epochData(opData.channelStream, opData.events, wn(1), wn(2));
        opDataOut.numEpochs = size(opDataOut.channelStream, 3);
        opDataOut.abscissa = 1:size(opDataOut.channelStream, 1);
        opDataOut.abscissa = opDataOut.abscissa ./ opDataOut.fs;
        opDataOut.abscissa = opDataOut.abscissa - wn(1) ./ opData.fs;
        opDataOut.epochExcludeStatus = zeros(opDataOut.numEpochs, 1);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function updateView(axH, opData)
    end
end