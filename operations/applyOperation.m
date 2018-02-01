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

ALL_OPERATIONS = {'Detrend', 'Normalize', 'Abs', 'Remove Common Mode', 'Resample',...
    'Filter', 'FFT', 'Spatial Filter',...
    'Select Channels', 'Create Epochs', 'Exclude Epochs',...
    'Channel Mean', 'Epoch Mean'};

opDataOut = opData;

switch operationName
    
    case ALL_OPERATIONS{1} % Detrend
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
        
    case ALL_OPERATIONS{2} % Normalize
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
        
    case ALL_OPERATIONS{3} % Abs
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
        
    case ALL_OPERATIONS{4} % Remove Common Mode
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
        
    case ALL_OPERATIONS{5} % Resample
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
        
    case ALL_OPERATIONS{6} % Filter
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
        
    case ALL_OPERATIONS{7} % FFT
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
        opDataOut.channelStream = processedData;
        opDataOut.abscissa = f;
        
        % Add custom updateView function
        opDataOut.updateView = @(axH, opD)fftUpdateView(axH, opD);
        
    case ALL_OPERATIONS{8} % Spatial Filter
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
        
    case ALL_OPERATIONS{9} % Select Channels
        % args{1} should be a vector with channel indices
        channelNums = args{1};
        opDataOut.channelStream = opData.channelStream(:, channelNums, :);
        opDataOut.numChannels = size(opDataOut.channelStream, 2);
        if(~isempty(opDataOut.channelNames))
            opDataOut.channelNames = opData.channelNames(channelNums);
        end
        
    case ALL_OPERATIONS{10} % Create Epochs
        % args{1} should be [timeBefore timeAfter]
        wn = round(args{1} .* opData.fs);
        opDataOut.channelStream = epochData(opData.channelStream, opData.events, wn(1), wn(2));
        opDataOut.numEpochs = size(opDataOut.channelStream, 3);
        opDataOut.abscissa = 1:size(opDataOut.channelStream, 1);
        opDataOut.abscissa = opDataOut.abscissa ./ opDataOut.fs;
        opDataOut.abscissa = opDataOut.abscissa - wn(1) ./ opData.fs;
        opDataOut.epochExcludeStatus = zeros(opDataOut.numEpochs, 1);
        
    case ALL_OPERATIONS{11} % Exclude Epochs
        % No argument required.
        opDataOut.channelStream = opData.channelStream(:,:, ~opData.epochExcludeStatus);
        opDataOut.numEpochs = size(opDataOut.channelStream, 3);
        opDataOut.epochExcludeStatus = zeros(opDataOut.numEpochs, 1);
        
    case ALL_OPERATIONS{12} % Channel Mean
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
        
    case ALL_OPERATIONS{13} % Epoch Mean
        % No argument required.
        opDataOut.channelStream = mean(opData.channelStream, 3);
        opDataOut.numEpochs = size(opDataOut.channelStream, 3);
        opDataOut.epochNum = 1;
        opDataOut.epochExcludeStatus = [];
    otherwise
        disp('Operation not implemented');
end

% Define custom updateView functions which take axis handle and opData as
% input
    function fftUpdateView(axH, opData)
        plot(axH, opData.abscissa, opData.channelStream(:,:, opData.epochNum));
        xlabel(axH, 'Frequency (Hz)');
        ylabel(axH, 'Amplitude');
    end
end