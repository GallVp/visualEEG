function [argFunc, opFunc] = eegBandsOliveira
%eegBands Finds the power in the EEG bands, then averages across
%   epochs and channels. This analysis is based on "Proposing
%   Metrics for Benchmarking Novel EEG Technologies Towards Real-World
%   Measurements", Oliveira et. al. 2016.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % No argument required.
        returnArgs = {'N.R.'};
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % No argument required.
        EEG_DELTA_RANGE                 = [0.05 3];
        EEG_THETA_RANGE                 = [3 8];
        EEG_ALPHA_RANGE                 = [8 12];
        EEG_BETA_RANGE                  = [12 38];
        
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            deltaPower = zeros(1, sz(2), sz(3));
            thetaPower = zeros(1, sz(2), sz(3));
            alphaPower = zeros(1, sz(2), sz(3));
            betaPower = zeros(1, sz(2), sz(3));
            for i=1:opData.numEpochs
                deltaPower(:, :, i) = 10 .* log10(bandpower(opData.channelStream(:, :, i), opData.fs, EEG_DELTA_RANGE));
                thetaPower(:, :, i) = 10 .* log10(bandpower(opData.channelStream(:, :, i), opData.fs, EEG_THETA_RANGE));
                alphaPower(:, :, i) = 10 .* log10(bandpower(opData.channelStream(:, :, i), opData.fs, EEG_ALPHA_RANGE));
                betaPower(:, :, i) = 10 .* log10(bandpower(opData.channelStream(:, :, i), opData.fs, EEG_BETA_RANGE));
            end
        else
            deltaPower = 10 .* log10(bandpower(opData.channelStream, opData.fs, EEG_DELTA_RANGE));
            thetaPower = 10 .* log10(bandpower(opData.channelStream, opData.fs, EEG_THETA_RANGE));
            alphaPower = 10 .* log10(bandpower(opData.channelStream, opData.fs, EEG_ALPHA_RANGE));
            betaPower = 10 .* log10(bandpower(opData.channelStream, opData.fs, EEG_BETA_RANGE));
        end
        opDataOut.deltaPowerMean    = mean(deltaPower(:));
        opDataOut.thetaPowerMean    = mean(thetaPower(:));
        opDataOut.alphaPowerMean    = mean(alphaPower(:));
        opDataOut.betaPowerMean     = mean(betaPower(:));
        
        opDataOut.deltaPowerStd     = std(deltaPower(:));
        opDataOut.thetaPowerStd     = std(thetaPower(:));
        opDataOut.alphaPowerStd     = std(alphaPower(:));
        opDataOut.betaPowerStd      = std(betaPower(:));
        
        opDataOut.deltaBand = EEG_DELTA_RANGE;
        opDataOut.thetaBand = EEG_THETA_RANGE;
        opDataOut.alphaBand = EEG_ALPHA_RANGE;
        opDataOut.betaBand = EEG_BETA_RANGE;
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
        errs = [opData.deltaPowerStd opData.thetaPowerStd opData.alphaPowerStd opData.betaPowerStd];
        data = [opData.deltaPowerMean opData.thetaPowerMean opData.alphaPowerMean opData.betaPowerMean];
        barwitherr(errs, data);
        xlabel(axH, 'Frequency (Hz)');
        ylabel(axH, 'Power (dB)');
        xticks(axH, [1 2 3 4]);
        xticklabels(axH, {sprintf('[%g %g]', opData.deltaBand(1), opData.deltaBand(2)),...
            sprintf('[%g %g]', opData.thetaBand(1), opData.thetaBand(2)),...
            sprintf('[%g %g]', opData.alphaBand(1), opData.alphaBand(2)),...
            sprintf('[%g %g]', opData.betaBand(1), opData.betaBand(2))});
        ax = axis;
        ax(1) = ax(1) - 0.5;
        ax(2) = ax(2) + 0.5;
        axis(ax);
    end
end