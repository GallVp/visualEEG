function [argFunc, opFunc] = refVsActivePSD
%refVsActivePSD Plots psd of reference segment vs the activity segment.
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
        CI_AT           = 1.96;
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
        opDataOut.referenceSpectra          = mean(referenceSpectra(1:length(f), :, :), 3);
        opDataOut.activitySpectra           = mean(activitySpectra(1:length(f), :, :), 3);
        opDataOut.diffInSpectra             = opDataOut.activitySpectra - opDataOut.referenceSpectra;
        opDataOut.diffInSpectraMean         = mean(opDataOut.diffInSpectra);
        opDataOut.diffInSpectraCI           = CI_AT .* std(opDataOut.diffInSpectra)...
            / sqrt(length(opDataOut.diffInSpectra));
        opDataOut.diffInSpectraCrosses      = opDataOut.diffInSpectra >= (opDataOut.diffInSpectraMean + opDataOut.diffInSpectraCI) |...
            opDataOut.diffInSpectra <= (opDataOut.diffInSpectraMean - opDataOut.diffInSpectraCI);
        opDataOut.diffInSpectraCrosses      = retainFirstAndLastOne(opDataOut.diffInSpectraCrosses);
        opDataOut.diffInSpectraCrosses(1)   = 0;
        opDataOut.diffInSpectraCrosses(end) = 0;
        opDataOut.diffInSpectraCrosses      = find(opDataOut.diffInSpectraCrosses);
        opDataOut.numEpochs                 = 1;
        opDataOut.epochNum                  = 1;
        opDataOut.raFreq                    = f;
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut           = opData;
        axHPosition         = axH.Position;
        cla(axH);
        axH.Visible         = 'off';
        
        ax1 = axes('Position',[axHPosition(1) axHPosition(2) axHPosition(3) axHPosition(4)/2.5]);
        
        plot(ax1, opData.raFreq, opData.referenceSpectra);
        hold on;
        plot(ax1, opData.raFreq, opData.activitySpectra);
        hold off;
        
        ax2 = axes('Position',[axHPosition(1)...
            axHPosition(2) + axHPosition(4)/2.5 + (axHPosition(4)/2.5)/4 ...
            axHPosition(3) axHPosition(4)/2.5]);
        plot(ax2, opData.raFreq, opData.diffInSpectra);
        hold on;
        plot(ax2, [opData.raFreq(1) opData.raFreq(end)], [opData.diffInSpectraMean opData.diffInSpectraMean], '-k');
        plot(ax2, [opData.raFreq(1) opData.raFreq(end)], opData.diffInSpectraMean + [opData.diffInSpectraCI opData.diffInSpectraCI], '--r');
        plot(ax2, [opData.raFreq(1) opData.raFreq(end)], opData.diffInSpectraMean - [opData.diffInSpectraCI opData.diffInSpectraCI], '--r');
        
        for i=1:length(opData.diffInSpectraCrosses)
            diffIndex = opData.diffInSpectraCrosses(i);
            plot(ax2, opData.raFreq(diffIndex), opData.diffInSpectra(diffIndex), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
            text(ax2, opData.raFreq(diffIndex), opData.diffInSpectra(diffIndex),...
                sprintf(' --> %.2f Hz', opData.raFreq(diffIndex)), 'FontSize', 12);
        end
        hold off;
        xlabel(ax1, 'Frequency (Hz)');
        ylabel(ax1, 'Power (dB)');
        ylabel(ax2, 'Power (dB)');
    end
end