function [opDataOut] = applyOperation(operationName, args,  opData)
%applyOperation
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.

OPERATIONS = {'Detrend', 'Normalize', 'Abs', 'Remove Common Mode', 'Resample',...
    'Filter', 'FFT', 'Spatial Filter',...
    'Select Channels', 'Create Epochs', 'Exclude Epochs',...
    'Channel Mean', 'Epoch Mean',...
    'Band Power', 'EEG Bands', 'BP Feat.'};

opDataOut = opData;

switch operationName
    
    case OPERATIONS{1} % Detrend
        % args{1} should be 'linear' or 'constant'
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                processedData(:, :, i) = detrend(opData.channelStream(:, :, i) , args{1});
            end
        else
            processedData = detrend(opData.channelStream, args{1});
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{2} % Normalize
        % No argument required.
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                processedData(:, :, i) = normalizeColumns(opData.channelStream(:, :, i) );
            end
        else
            processedData = normalizeColumns(opData.channelStream);
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{3} % Abs
        % No argument required.
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                processedData(:, :, i) = abs(opData.channelStream(:, :, i));
            end
        else
            processedData = abs(opData.channelStream);
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{4} % Remove Common Mode
        % No argument required.
        M=eye(opData.numChannels)-1/opData.numChannels*ones(opData.numChannels);
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                processedData(:, :, i) = opData.channelStream(:, :, i) * M;
            end
        else
            processedData = opData.channelStream * M;
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{5} % Resample
        % args{1} should be p and args{2} should be q. p/q is
        % the sampling ratio.
        p = args{1};
        q = args{2};
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(sz(1) * p / q, sz(2), sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = resample(opData.channelStream(:, :, i), p, q);
            end
        else
            processedData   = resample(opData.channelStream, p, q);
        end
        opDataOut.channelStream = processedData;
        opDataOut.fs            = opData.fs * p / q;
        opDataOut.abscissa = 1:size(opDataOut.channelStream, 1);
        opDataOut.abscissa = opDataOut.abscissa ./ opDataOut.fs;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{6} % Filter
        % args{1} should be isBandStop and args{2} should be frequencyBand
        FILTER_ORDER    = 2;
        ZERO_PHASE      = 1;
        isBandStop = args{1};
        frequencyBand = args{2};
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                if(isBandStop)
                    processedData(:, :, i) = notchStream(opData.channelStream(:, :, i), opData.fs, frequencyBand);
                else
                    processedData(:, :, i) = filterStream(opData.channelStream(:, :, i), opData.fs,...
                        FILTER_ORDER, frequencyBand(2), frequencyBand(1), ZERO_PHASE);
                end
            end
        else
            if(isBandStop)
                processedData = notchStream(opData.channelStream, opData.fs, frequencyBand);
            else
                processedData = filterStream(opData.channelStream, opData.fs,...
                    FILTER_ORDER, frequencyBand(2), frequencyBand(1), ZERO_PHASE);
            end
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{7} % FFT
        % No argument required.
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                [x, f] = computeFFT(opData.channelStream(:, :, i), opData.fs);
                processedData(1:length(f), :, i) = x;
            end
            processedData = processedData(1:length(f), :, :);
        else
            [processedData, f] = computeFFT(opData.channelStream, opData.fs);
        end
        opDataOut.frequencyStream = processedData;
        opDataOut.fftFreq = f;
        
        % Add custom updateView function
        opDataOut.updateView = @(axH, opD)fftUpdateView(axH, opD);
        
    case OPERATIONS{8} % Spatial Filter
        % args{1} should be channel weights
        M = args{1};
        M =M';
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(sz(1), 1, sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = opData.channelStream(:, :, i) * M;
            end
        else
            processedData = opData.channelStream * M;
        end
        opDataOut.channelStream = processedData;
        opDataOut.channelNames = {'SF Channel'};
        opDataOut.numChannels = size(opDataOut.channelStream, 2);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{9} % Select Channels
        % args{1} should be a vector with channel indices
        channelNums = args{1};
        opDataOut.channelStream = opData.channelStream(:, channelNums, :);
        opDataOut.numChannels = size(opDataOut.channelStream, 2);
        if(~isempty(opDataOut.channelNames))
            opDataOut.channelNames = opData.channelNames(channelNums);
        end
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{10} % Create Epochs
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
        
    case OPERATIONS{11} % Exclude Epochs
        % No argument required.
        opDataOut.channelStream = opData.channelStream(:,:, ~opData.epochExcludeStatus);
        opDataOut.numEpochs = size(opDataOut.channelStream, 3);
        opDataOut.epochExcludeStatus = zeros(opDataOut.numEpochs, 1);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{12} % Channel Mean
        % No argument required.
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(sz(1), 1, sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = mean(opData.channelStream(:, :, i), 2);
            end
        else
            processedData = mean(opData.channelStream, 2);
        end
        opDataOut.channelStream = processedData;
        opDataOut.channelNames = {'Mean Channel'};
        opDataOut.numChannels = size(opDataOut.channelStream, 2);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{13} % Epoch Mean
        % No argument required.
        opDataOut.channelStream = mean(opData.channelStream, 3);
        opDataOut.numEpochs = size(opDataOut.channelStream, 3);
        opDataOut.epochNum = 1;
        opDataOut.epochExcludeStatus = [];
        
        % Remove custom updateView function
        opDataOut.updateView = [];
        
    case OPERATIONS{14} % Band Power
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
        opDataOut.updateView = @(axH, opD)bpUpdateView(axH, opD);
        
    case OPERATIONS{15} % EEG Bands
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
        opDataOut.deltaPower    = deltaPower;
        opDataOut.thetaPower    = thetaPower;
        opDataOut.alphaPower    = alphaPower;
        opDataOut.betaPower     = betaPower;
        
        opDataOut.deltaBand = EEG_DELTA_RANGE;
        opDataOut.thetaBand = EEG_THETA_RANGE;
        opDataOut.alphaBand = EEG_ALPHA_RANGE;
        opDataOut.betaBand = EEG_BETA_RANGE;
        % Add custom updateView function
        opDataOut.updateView = @(axH, opD)ebUpdateView(axH, opD);
        
    case OPERATIONS{16} % BP Feat.
        % No argument required.
        PN_WIN          = [-0.5 0.5];
        PN_WIN_LOGICAL  = opData.abscissa >= PN_WIN(1) & opData.abscissa <= PN_WIN(2);
        BP_IS_AT        = -2; %In seconds. Negative means before.
        bpIndex         = find(abs(opData.abscissa - BP_IS_AT) <= 1/opData.fs, 1);
        BP2_IS_AT       = -0.5; %In seconds. Negative means before.
        bp2Index        = find(abs(opData.abscissa - BP2_IS_AT) <= 1/opData.fs, 1);
        
        if(opData.numEpochs > 1)
            sz              = size(opData.channelStream);
            pnValue         = zeros(1, sz(2), sz(3));
            pnTime          = zeros(1, sz(2), sz(3));
            bp2Value        = zeros(1, sz(2), sz(3));   % If data is epoched, it is calculated otherwise []
            bpValue         = zeros(1, sz(2), sz(3));   % If data is epoched, it is calculated otherwise []
            for i=1:opData.numEpochs
                pnValue(:, :, i) = min(opData.channelStream(PN_WIN_LOGICAL, :, i));
                for j=1:opData.numChannels
                    % Calculated with respect to current epoch indices
                    pnTime(:, j, i) = opData.abscissa(find(opData.channelStream(:, j, i) == pnValue(:, j, i), 1));
                end
                if(~isempty(bpIndex))
                    bpValue(:, :, i) = opData.channelStream(bpIndex, :, i);
                else
                    bpValue(:, :, i) = [];
                end
                if(~isempty(bp2Index))
                    bp2Value(:, :, i) = opData.channelStream(bp2Index, :, i);
                else
                    bp2Value(:, :, i) = [];
                end
            end
        else
            pnValue = min(opData.channelStream(PN_WIN_LOGICAL, :, :));
            for j=1:opData.numChannels
                % Calculated with respect to current epoch indices
                pnTime(:, j) = opData.abscissa(find(opData.channelStream(:, j) == pnValue(:, j), 1));
            end
            if(~isempty(bpIndex))
                bpValue = opData.channelStream(bpIndex, :);
            else
                bpValue = [];
            end
            if(~isempty(bp2Index))
                bp2Value = opData.channelStream(bp2Index, :);
            else
                bp2Value = [];
            end
        end
        opDataOut.pnValue    = pnValue;
        opDataOut.pnTime     = pnTime;
        opDataOut.bpValue    = bpValue;
        opDataOut.bp2Value   = bp2Value;
        
        opDataOut.BP_IS_AT  = BP_IS_AT;
        opDataOut.BP2_IS_AT = BP2_IS_AT;
        % Add custom updateView function
        opDataOut.updateView = @(axH, opD)bp2UpdateView(axH, opD);
        
    otherwise
        disp('Operation not implemented');
end

% Define custom updateView functions which take axis handle and opData as
% input
    function fftUpdateView(axH, opData) % FFT
        plot(axH, opData.fftFreq, opData.frequencyStream(:,:, opData.epochNum));
        xlabel(axH, 'Frequency (Hz)');
        ylabel(axH, 'Amplitude');
    end
    function bpUpdateView(axH, opData) % Band Power
        plot(axH, 1, opData.bandPower(:,:, opData.epochNum), 'x', 'LineWidth', 2, 'MarkerSize', 12);
        xlabel(axH, 'Frequency (Hz)');
        xticks(axH, 1);
        xticklabels(axH, sprintf('[%g %g]', opData.frequencyBand(1), opData.frequencyBand(2)));
        ylabel(axH, 'Power (dB)');
    end
    function ebUpdateView(axH, opData) % Band Power
        plot(axH, 1, opData.deltaPower(:,:, opData.epochNum), 'x', 'LineWidth', 2, 'MarkerSize', 12);
        hold on;
        plot(axH, 2, opData.thetaPower(:,:, opData.epochNum), 'x', 'LineWidth', 2, 'MarkerSize', 12);
        plot(axH, 3, opData.alphaPower(:,:, opData.epochNum), 'x', 'LineWidth', 2, 'MarkerSize', 12);
        plot(axH, 4, opData.betaPower(:,:, opData.epochNum), 'x', 'LineWidth', 2, 'MarkerSize', 12);
        hold off;
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
    function bp2UpdateView(axH, opData) % BP Feat.
        % Plot data
        dat = opData.channelStream;
        
        if(size(dat, 2) > 128)
            disp('Warning: Only plotting first 128 channels');
            dat = dat(:, 1:128);
        end
        absc = opData.abscissa;
        
        plot(axH, absc, dat(:,:, opData.epochNum));
        % Set axis labels
        xlabel('Time (s)');
        ylabel('Amplitude');
        
        % Plot pn point
        hold on;
        plot(axH, opData.pnTime(:,:, opData.epochNum), opData.pnValue(:,:, opData.epochNum), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
        for jthChannel=1:opData.numChannels
        text(axH, opData.pnTime(:, jthChannel, opData.epochNum), opData.pnValue(:, jthChannel, opData.epochNum), sprintf(' --> PN(%g, %g)',...
            opData.pnTime(:, jthChannel, opData.epochNum), opData.pnValue(:, jthChannel, opData.epochNum)), 'FontSize', 12);
        end
        
        % Plot BP point
        if(~isempty(opData.bpValue))
            plot(axH, opData.BP_IS_AT, opData.bpValue(:,:, opData.epochNum), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
        end
        for jthChannel=1:opData.numChannels
        text(axH, opData.BP_IS_AT, opData.bpValue(:, jthChannel, opData.epochNum), sprintf(' --> BP(%g, %g)',...
            opData.BP_IS_AT, opData.bpValue(:, jthChannel, opData.epochNum)), 'FontSize', 12);
        end
        
        % Plot BP2 point
        if(~isempty(opData.bp2Value))
            plot(axH, opData.BP2_IS_AT, opData.bp2Value(:,:, opData.epochNum), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
        end
        for jthChannel=1:opData.numChannels
        text(axH, opData.BP2_IS_AT, opData.bp2Value(:, jthChannel, opData.epochNum), sprintf(' --> BP2(%g, %g)',...
            opData.BP2_IS_AT, opData.bp2Value(:, jthChannel, opData.epochNum)), 'FontSize', 12);
        end
        hold off;
    end
end