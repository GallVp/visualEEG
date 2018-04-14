function [argFunc, opFunc] = bandPower
%bandPower Finds power in the specified band
%
% Copyright (c) <2016> <Usman Rashid>
% Licensed under the MIT License. See License.txt in the project root for
% license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be frequencyBand
        prompt = {'Frequency band [fHigh fLow]:'};
        dlg_title = 'Band Power';
        num_lines = 1;
        defaultans = {'[0.05 5]'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        frequencyBand = str2num(answer{1});
        if(isempty(frequencyBand))
            returnArgs = {};
        else
            if(isnan(frequencyBand(1)) || isnan(frequencyBand(2))...
                    || frequencyBand(2) <= frequencyBand(1))
                returnArgs = {};
            else
                returnArgs = {frequencyBand};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be frequencyBand
        frequencyBand = args{1};
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(1, sz(2), sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = 10 .* log10(bandpower(opData.channelStream(:, :, i), opData.fs, frequencyBand));
            end
        else
            processedData = 10 .* log10(bandpower(opData.channelStream, opData.fs, frequencyBand));
        end
        opDataOut.bandPower = processedData;
        opDataOut.frequencyBand = frequencyBand;
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function updateView(axH, opData)
        plot(axH, 1, opData.bandPower(:,:, opData.epochNum), 'x', 'LineWidth', 2, 'MarkerSize', 12);
        xlabel(axH, 'Frequency (Hz)');
        xticks(axH, 1);
        xticklabels(axH, sprintf('[%g %g]', opData.frequencyBand(1), opData.frequencyBand(2)));
        ylabel(axH, 'Power (dB)');
    end
end