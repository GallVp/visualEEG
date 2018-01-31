function [opDataOut] = applyOperation(operationName, args,  opData)
% applyOperation
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
                [processedData(:, :, i), f] = computeFFT(opData.channelStream(:, :, i), opData.fs);
            end
        else
            [processedData, f] = computeFFT(opData.channelStream, opData.fs);
        end
        opDataOut.channelStream = processedData;
        opDataOut.abscissa = f;
        
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
        
        
%     case ALL_OPERATIONS{8} % PCA
%         % No argument required.
%         [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
%         if(strcmp(obj.dataChangeName, eegData.EVENT_NAME_CHANNELS_CHANGED) || isempty(obj.storedArgs.('eignVect')))
%             try
%                 [eignVectors, ~] = pcamat(P',1,2,'gui');
%                 
%             catch me
%                 disp(me.identifier);
%                 eignVectors = eye(size(P));
%             end
%             obj.storedArgs.('eignVect') = eignVectors;
%             obj.dataChangeName = [];
%         else
%             eignVectors = obj.storedArgs.('eignVect');
%         end
%         proc = P * eignVectors;
%         channelNums = 1:size(proc, 2);
%         channelNames = cell(size(proc, 2), 1);
%         for i=1:size(proc, 2)
%             channelNames = sprintf('c%s',i);
%         end
%         obj.procData.setChannelData(eegOperations.shapeSst(proc, nT), channelNums, channelNames);
%         
%         
%         
%     case eegOperations.ALL_OPERATIONS{9} % FAST ICA
%         % No argument required.
%         [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
%         proc = fastica(P');
%         proc = proc';
%         channelNums = 1:size(proc, 2);
%         channelNames = cell(size(proc, 2), 1);
%         for i=1:size(proc, 2)
%             channelNames = sprintf('c%s',i);
%         end
%         obj.procData.setChannelData(eegOperations.shapeSst(proc, nT), channelNums, channelNames); 
    otherwise
        disp('Operation not implemented');
end
end