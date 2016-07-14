function applyOperation(obj, operationName, args,  processingData)
switch operationName
    case eegOperations.ALL_OPERATIONS{1} % Mean
        % No argument required.
        channelNums = 1;
        channelName = 'Mean';
        obj.procData.setChannelData(mean(processingData.selectedData, 2), channelNums, channelName);
        
        
        
    case eegOperations.ALL_OPERATIONS{2} % Grand Mean
        % No argument required.
        obj.procData.setGrandData(mean(processingData.selectedData, 3));
        
        
        
    case eegOperations.ALL_OPERATIONS{3} % Detrend
        % args{1} should be 'linear' or 'constant'
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        P = detrend(P, args{1});
        obj.procData.setSelectedData(eegOperations.shapeSst(P, nT));
        
        
        
    case eegOperations.ALL_OPERATIONS{4} % Normalize
        % No argument required.
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        P = normc(P);
        obj.procData.setSelectedData(eegOperations.shapeSst(P, nT));
        
        
        
        
    case eegOperations.ALL_OPERATIONS{5} % Filter
        % args{1} should be a filter object obtained from designfilter.
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        % Padding 64 samples
        P = [P(1:64,:);P];
        P = filter(args{1}, P);
        P = P(65:end,:);
        P = eegOperations.shapeSst(P, nT);
        obj.procData.setSelectedData(P);
        
        
        
        
    case eegOperations.ALL_OPERATIONS{6} % FFT
        % args{1} should be the data rate.
        P = processingData.selectedData;
        [m, n, o] = size(P);
        proc = zeros(floor(m/2) + 1, n, o);
        for i=1:o
            [proc(:,:,i), f] = computeFFT(P(:,:,i), processingData.dataRate);
        end
        obj.procData.setFrequencyData(proc, f);
        
        
        
    case eegOperations.ALL_OPERATIONS{7} % Spatial Laplacian
        % No argument required.
        if(strcmp(obj.dataChangeName, eegData.EVENT_NAME_CHANNELS_CHANGED) || isempty(obj.storedArgs.('sLCentre')))
            options = processingData.channelNames;
            [s,~] = listdlg('PromptString','Select centre:', 'SelectionMode','single',...
                'ListString', options);
            centre = processingData.channelNums(s);
            obj.storedArgs.('sLCentre') = centre;
            obj.dataChangeName = [];
        else
            centre = obj.storedArgs.('sLCentre');
        end
        filterCoffs = -1 .* ones(processingData.dataSize(2), 1) ./ ((processingData.dataSize(2)) - 1);
        filterCoffs(centre) = 1;
        channelName = sprintf('Surrogate of %s',processingData.channelNames{centre});
        channelNums = 1;
        obj.procData.setChannelData(spatialFilterSstData(processingData.selectedData, filterCoffs), channelNums, channelName);
        
        
        
    case eegOperations.ALL_OPERATIONS{8} % PCA
        % No argument required.
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        if(strcmp(obj.dataChangeName, eegData.EVENT_NAME_CHANNELS_CHANGED) || isempty(obj.storedArgs.('eignVect')))
            try
                [eignVectors, ~] = pcamat(P',1,2,'gui');
                
            catch me
                disp(me.identifier);
                eignVectors = eye(size(P));
            end
            obj.storedArgs.('eignVect') = eignVectors;
            obj.dataChangeName = [];
        else
            eignVectors = obj.storedArgs.('eignVect');
        end
        proc = P * eignVectors;
        channelNums = 1:size(proc, 2);
        channelNames = cell(size(proc, 2), 1);
        for i=1:size(proc, 2)
            channelNames = sprintf('c%s',i);
        end
        obj.procData.setChannelData(eegOperations.shapeSst(proc, nT), channelNums, channelNames);
        
        
        
    case eegOperations.ALL_OPERATIONS{9} % FAST ICA
        % No argument required.
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        proc = fastica(P');
        proc = proc';
        channelNums = 1:size(proc, 2);
        channelNames = cell(size(proc, 2), 1);
        for i=1:size(proc, 2)
            channelNames = sprintf('c%s',i);
        end
        obj.procData.setChannelData(eegOperations.shapeSst(proc, nT), channelNums, channelNames);
        
        
        
        
    case eegOperations.ALL_OPERATIONS{10} % Optimal SF
        % args{1} should be a 1 by 2 vector containing signal
        % time. args{2} should be a 1 by 2 vector containing
        % noise time. arg{3} should be 1/0 for per epoch
        % processing
        signalInterval = args{1};
        if(~isempty(args{2}))
            noiseInterval = args{2};
            noiseInterval = noiseInterval(1) + 1/processingData.dataRate:1/processingData.dataRate:noiseInterval(2);
        else
            noiseInterval = [0 signalInterval(1) signalInterval(2) processingData.interval(2)];
            noiseInterval = [noiseInterval(1) + 1/processingData.dataRate:1/processingData.dataRate:noiseInterval(2)...
                noiseInterval(3) + 1/processingData.dataRate:1/processingData.dataRate:noiseInterval(4)];
        end
        signalInterval = signalInterval(1) + 1/processingData.dataRate:1/processingData.dataRate:signalInterval(2);
        
        signalInterval = round(signalInterval .* processingData.dataRate);
        noiseInterval = round(noiseInterval .* processingData.dataRate);
        signalData = processingData.selectedData(signalInterval,:,:);
        noiseData = processingData.selectedData(noiseInterval,:,:);
        
        if(args{3})
            proc = zeros(size(processingData.selectedData, 1), 1, size(processingData.selectedData, 3));
            
            for i = 1:size(signalData, 3)
                w = osf(signalData(:,:,i)', noiseData(:,:,i)');
                proc(:,:,i) = spatialFilterSstData(processingData.selectedData(:,:,i), w);
            end
        else
            [signalData, ~] = eegOperations.shapeProcessing(signalData);
            [noiseData, ~] = eegOperations.shapeProcessing(noiseData);
            w = osf(signalData', noiseData');
            [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
            proc =  P * w;
            proc = eegOperations.shapeSst(proc, nT);
        end
        
        channelName = 'Optimal surrogate';
        channelNums = 1;
        obj.procData.setChannelData(proc, channelNums, channelName);
        
        
        
    case eegOperations.ALL_OPERATIONS{11} % Threshold by Std.
        % args{1} should be number of stds to use.
        numEpochs = processingData.dataSize(3);
        numChannels = processingData.dataSize(2);
        numStds = args{1};
        proc = zeros(size(processingData.selectedData));
        for i=1:numEpochs
            for j=1:numChannels
                dataStd = std(processingData.selectedData(:,j, i));
                proc(:, j, i) = processingData.selectedData(:, j, i) > dataStd * numStds;
            end
        end
        obj.procData.setSelectedData(proc);
        
        
        
    case eegOperations.ALL_OPERATIONS{12} % Abs
        % No argument required.
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        proc = abs(P);
        proc = eegOperations.shapeSst(proc, nT);
        obj.procData.setSelectedData(proc);
        
        
        
    case eegOperations.ALL_OPERATIONS{13} % Detect Peak
        % args{1} should be the threshold amplitude. args{2}
        % should be the peak number.
        numEpochs = processingData.dataSize(3);
        numChannels = processingData.dataSize(2);
        numSamples = processingData.dataSize(1);
        thresh = args{1};
        peakNumber = args{2};
        proc = zeros(size(processingData.selectedData));
        for i=1:numEpochs
            for j=1:numChannels
                pn = 0;
                for k=1:numSamples
                    if(processingData.selectedData(k,j,i) >= thresh)
                        pn = pn +1;
                        if(peakNumber == 0)
                            proc(k,j,i) = 1;
                            continue;
                        elseif(peakNumber == pn)
                            proc(k,j,i) = 1;
                            break;
                        else
                            continue;
                        end
                    else
                        continue;
                    end
                end
            end
        end
        obj.procData.setSelectedData(proc);
        
        
        
    case eegOperations.ALL_OPERATIONS{14} % Shift with EMG Cue
        % args{1} should be combination Number (always 1). args{2} should be the data set
        % number. args{3} should be operation set number.
        % Prepare data to be combined
        combineType = args{1};
        dSetNum = args{2};
        opSetNum = args{3};
        obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
        combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
        
        if(processingData.dataSize(1) == combineData.dataSize(1))
            numEpochs = processingData.dataSize(3);
            proc = zeros(size(processingData.selectedData));
            for i=1:numEpochs
                absoluteEpochNum = processingData.getAbsoluteEpochNum(i);
                if(combineData.isEpochPresent(absoluteEpochNum))
                    trigger = combineData.abscissa(combineData.selectedData(:,2,absoluteEpochNum)==1);
                    cue = combineData.abscissa(combineData.selectedData(:,1,absoluteEpochNum)==1);
                    n = round((cue - trigger) * obj.dataSet.dataRate);
                    if(n < 0)
                        proc(1:end+n,:,i) = processingData.selectedData(-n+1:end,:,i);
                    else
                        proc(n+1:end,:,i) = processingData.selectedData(1:end-n,:,i);
                    end
                else
                    proc(:,:,i) = processingData.selectedData(:,:,i);
                    continue;
                end
                
            end
            obj.procData.setSelectedData(proc);
        else
            uiwait(errordlg(strcat('Shifting failed due to size mismatch.',...
                sprintf('\nSource samples: %d\nDest. samples: %d',...
                combineData.dataSize(1), processingData.dataSize(1))), 'Shifting Operation', 'modal'));
        end
        
        
        
        
    case eegOperations.ALL_OPERATIONS{15} % Remove Common Mode
        % No argument required.
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        numChannels = processingData.dataSize(2);
        M=eye(numChannels)-1/numChannels*ones(numChannels);
        proc= P * M;
        proc = eegOperations.shapeSst(proc, nT);
        obj.procData.setSelectedData(proc);
        
        
        
    case eegOperations.ALL_OPERATIONS{16} % Group Epochs
        % args{1} should be total number of groups, while
        % args{2} should be the selected group's number.
        obj.procData.selectEpochGroup(args{1}, args{2});
        
        
        
    case eegOperations.ALL_OPERATIONS{17} % Shift Cue
        % args{1} should be a vector of delays. Number of
        % elements will determine number of cues.
        obj.procData.shiftCues(args{1})
        
        
        
    case eegOperations.ALL_OPERATIONS{18} % Combine Data
        % args{1} should be combination Number refering to
        % COMBINE_OPTIONS. args{2} should be the data set
        % number. args{3} should be operation set number.
        
        % Prepare data to be combined
        combineType = args{1};
        dSetNum = args{2};
        opSetNum = args{3};
        obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
        combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
        
        switch (combineType)
            case 1
                if(processingData.dataSize(1) == combineData.dataSize(1) && processingData.dataSize(3) == combineData.dataSize(3))
                    selectedData = cat(2,processingData.selectedData, combineData.selectedData);
                    channelNums = [processingData.channelNums combineData.channelNums];
                    channelNames = [processingData.channelNames ; combineData.channelNames];
                    obj.procData.setChannelData(selectedData, channelNums, channelNames);
                else
                    uiwait(errordlg(strcat('Combination failed due to size mismatch.',...
                        sprintf('\nSource samples: %d\nDest. samples: %d\nSource epochs: %d\nDest. epochs: %d',...
                        combineData.dataSize(1), processingData.dataSize(1), combineData.dataSize(3),...
                        processingData.dataSize(3))), 'Combination Operation', 'modal'));
                end
            otherwise
                disp('Combination operation not implemented');
        end
        
        
        
    case eegOperations.ALL_OPERATIONS{19} % Resample
        % args{1} should be p and args{2} should be q. p/q is
        % the sampling ratio.
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        p = args{1};
        q = args{2};
        proc = resample(P, p, q);
        proc = eegOperations.shapeSst(proc, nT);
        obj.procData.setResampledData(proc, processingData.dataRate * p / q);
        
        
        
    case eegOperations.ALL_OPERATIONS{20} % Delay
        % args{1} should be delay time in seconds
        numEpochs = processingData.dataSize(3);
        delay = args{1};
        proc = zeros(size(processingData.selectedData));
        for i=1:numEpochs
            n = round(delay * processingData.dataRate);
            if(n < 0)
                proc(1:end+n,:,i) = processingData.selectedData(-n+1:end,:,i);
            else
                proc(n+1:end,:,i) = processingData.selectedData(1:end-n,:,i);
            end
        end
        obj.procData.setSelectedData(proc);
        
        
        
    case eegOperations.ALL_OPERATIONS{21} % Gain
        % args{1} should be gain
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        gain = args{1};
        proc = P .* gain;
        proc = eegOperations.shapeSst(proc, nT);
        obj.procData.setSelectedData(proc);
        
        
        
    case eegOperations.ALL_OPERATIONS{22} % Detect EMG Cue
        % No argument required.
        % take absolute
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        proc = abs(P);
        proc = eegOperations.shapeSst(proc, nT);
        
        numEpochs = processingData.dataSize(3);
        numChannels = processingData.dataSize(2);
        numStds = 2;
        for i=1:numEpochs
            for j=1:numChannels
                dataStd = std(proc(:,j, i));
                proc(:, j, i) = proc(:, j, i) > dataStd * numStds;
            end
        end
        
        numSamples = processingData.dataSize(1);
        thresh = 1;
        peakNumber = 1;
        proc2 = zeros(size(processingData.selectedData));
        for i=1:numEpochs
            for j=1:numChannels
                pn = 0;
                for k=1:numSamples
                    if(proc(k,j,i) >= thresh)
                        pn = pn +1;
                        if(peakNumber == 0)
                            proc2(k,j,i) = 1;
                            continue;
                        elseif(peakNumber == pn)
                            proc2(k,j,i) = 1;
                            break;
                        else
                            continue;
                        end
                    else
                        continue;
                    end
                end
            end
        end
        obj.procData.setTimeEventData(proc2);
        
        
        
    case eegOperations.ALL_OPERATIONS{23} % Two Segment SVM Train
        % args = {s1s, s1e, s2s, s2e, c, p, permu};
        [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
        proc = abs(P);
        proc = eegOperations.shapeSst(proc, nT);
        obj.procData.setSelectedData(proc);
        % No argument required.
        
        s1s = args{1};
        s1e = args{2};
        s2s = args{3};
        s2e = args{4};
        c = args{5};
        p = args{6};
        permu = args{7};
        
        [X,y] = sstData.splitData(processingData.selectedData, [s1s s1e], [s2s s2e], processingData.dataRate, permu);
        model = svmTrain(X, y, c, @linearKernel, 1e-3, p);
        pred = svmPredict(model, X);
        uiwait(msgbox(strcat('Training Set Accuracy:', sprintf(' %f',...
            mean(double(pred == y)) * 100)),'Training results'));
        
        obj.procData.setPredictionData(y, pred);
        obj.storedArgs.('SVM_Model') = {model, [s1s s1e], [s2s s2e], p};
        
        
        
    case eegOperations.ALL_OPERATIONS{24} % Two Segment SVM Test
        % args{1} should be combination Number refering to
        % COMBINE_OPTIONS. args{2} should be the data set
        % number. args{3} should be operation set number.
        
        % Prepare data to be combined
        combineType = args{1};
        dSetNum = args{2};
        opSetNum = args{3};
        obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
        model = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).storedArgs.('SVM_Model');
        permu = 1; % Sequential
        [X,y] = sstData.splitData(processingData.selectedData, model{2}, model{3}, processingData.dataRate, permu);
        pred = svmPredict(model{1}, X);
        uiwait(msgbox(strcat('Testing Set Accuracy:', sprintf(' %f',...
            mean(double(pred == y)) * 100)),'Testing results'));
        
        obj.procData.setPredictionData(y, pred);
        
        
        
    case eegOperations.ALL_OPERATIONS{25} % Two Segment SVM Validate
        % returnArgs = {Combination Number, Dataset Number,
        % Operationset Number, cInit, cStep, cFinal}. Where C
        % is regularization parameter
        
        % Prepare data to be combined
        combineType = args{1};
        dSetNum = args{2};
        opSetNum = args{3};
        cInit = args{4};
        cStep = args{5};
        cFinal = args{6};
        obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
        model = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).storedArgs.('SVM_Model');
        combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
        permu = 0; % Random
        [X,y] = sstData.splitData(processingData.selectedData, model{2}, model{3}, processingData.dataRate, permu);
        cRange = cInit:cStep:cFinal;
        
        accur = zeros(length(cRange), 2);
        
        for i=1:length(cRange)
            model = svmTrain(X, y, cRange(i), @linearKernel, 1e-3, model{4});
            pred = svmPredict(model, X);
            predCv = svmPredict(model, handles.Xcv);
            
            accur(i,1) = mean(double(pred == handles.y)) * 100;
            accur(i,2) = mean(double(predCv == handles.ycv)) * 100;
        end
        obj.procData.setPredictionData(y, pred);
        
        
        
    otherwise
        disp('Operation not implemented');
end
end