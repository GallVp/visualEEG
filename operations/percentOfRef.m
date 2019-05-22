function [argFunc, opFunc] = percentOfRef
%percentOfRef Plots the percentage of signal amplitude with respect to
%   the mean of reference segment.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be referencePeriod
        prompt = {'Reference interval:'};
        dlg_title = 'Percentage of reference segment';
        num_lines = 1;
        defaultans = {'[]'};
        answer = inputdlg(prompt, dlg_title, num_lines, defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        refPeriod = str2num(answer{1});
        if(isempty(refPeriod))
            returnArgs = {};
        else
            returnArgs = {refPeriod};
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be referencePeriod
        referencePeriod = args{1};
        
        referenceData = opData.channelStream(opData.abscissa > referencePeriod(1) & opData.abscissa <= referencePeriod(2), :, :);
        
        referenceData = mean(referenceData, 1);
        
        opDataOut.channelStream = (opDataOut.channelStream - referenceData) ./ referenceData .* 100;
        
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut           = opData;
        plot(opData.abscissa, opData.channelStream(:, :, opData.epochNum));
        xlabel('Time (s)');
        ylabel('Percentage (%)');
    end
end