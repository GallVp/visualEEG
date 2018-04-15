function [argFunc, opFunc] = raPSD
%raPSD Plots psd of reference segment vs the activity segment.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be referencePeriod and args{2} should be
        % activityPeriod.
        if(opData.numChannels > 1 || opData.numEpochs == 1)
            h = errordlg(sprintf('Operation only applicable to data with\none channel and multiple epochs.'),...
                'raPSD', 'modal');
            uiwait(h);
            returnArgs = {};
            return;
        end
        prompt = {'Reference interval:', 'Activity interval:'};
        dlg_title = 'Reference/Activity PSD';
        num_lines = 1;
        defaultans = {'[]', '[]'};
        answer = inputdlg(prompt, dlg_title, num_lines, defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        refPeriod = str2num(answer{1});
        actPeriod = str2num(answer{2});
        if(isempty(refPeriod) || isempty(actPeriod))
            returnArgs = {};
        else
            returnArgs = {refPeriod, actPeriod};
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % No argument required.
        FREQ_LIMIT      = 38;
        referencePeriod = args{1};
        activityPeriod  = args{2};
        
        referenceData = opData.channelStream(opData.abscissa > referencePeriod(1) & opData.abscissa <= referencePeriod(2), :, :);
        activityData = opData.channelStream(opData.abscissa > activityPeriod(1) & opData.abscissa <= activityPeriod(2), :, :);
        
        referenceSpectra = zeros(size(opData.channelStream));
        activitySpectra = zeros(size(opData.channelStream));
        for i=1:opData.numEpochs
            [x, f] = computePSD(referenceData(:, :, i), opData.fs);
            f = f(f<=FREQ_LIMIT);
            referenceSpectra(1:length(f), :, i) = x(f<=FREQ_LIMIT);
            
            [x, f] = computePSD(activityData(:, :, i), opData.fs);
            f = f(f<=FREQ_LIMIT);
            activitySpectra(1:length(f), :, i) = x(f<=FREQ_LIMIT);
        end
        % Take mean across epochs
        opDataOut.referenceSpectra  = mean(referenceSpectra(1:length(f), :, :), 3);
        opDataOut.activitySpectra   = mean(activitySpectra(1:length(f), :, :), 3);
        opDataOut.diffInSpectra     = opDataOut.activitySpectra - opDataOut.referenceSpectra;
        opDataOut.numEpochs         = 1;
        opDataOut.raFreq = f;
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function updateView(axH, opData)
        PLOT_CI_AT = 1.96;
        plot(axH, opData.raFreq, opData.diffInSpectra);
        hold on;
        diffMean = mean(opData.activitySpectra - opData.referenceSpectra);
        diffCI = PLOT_CI_AT * std(opData.activitySpectra - opData.referenceSpectra) / sqrt(length(opData.activitySpectra));
        plot(axH, [opData.raFreq(1) opData.raFreq(end)], [diffMean diffMean], '-k');
        plot(axH, [opData.raFreq(1) opData.raFreq(end)], diffMean + [diffCI diffCI], '--r');
        plot(axH, [opData.raFreq(1) opData.raFreq(end)], diffMean - [diffCI diffCI], '--r');
        hold off;
        xlabel(axH, 'Frequency (Hz)');
        ylabel(axH, 'Power (dB)');
    end
end