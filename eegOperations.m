classdef eegOperations < matlab.mixin.Copyable
    
    
    
    % Copyright (c) <2016> <Usman Rashid>
    %
    % This program is free software; you can redistribute it and/or
    % modify it under the terms of the GNU General Public License as
    % published by the Free Software Foundation; either version 2 of the
    % License, or (at your option) any later version.  See the file
    % LICENSE included with this distribution for more information.
    
    
    
    properties (Constant)
        ALL_OPERATIONS = {'Mean', 'Grand Mean', 'Detrend', 'Normalize', 'Filter', 'FFT', 'Spatial Laplacian',...
            'PCA', 'FAST ICA', 'Optimal SF', 'Threshold by Std.', 'Abs', 'Detect Peak', 'Shift with EMG Cue',...
            'Remove Common Mode', 'Group Epochs', 'Shift Cue', 'Combine Data', 'Resample', 'Delay', 'Gain', 'Detect EMG Cue',...
            'Two Segment SVM Train', 'Two Segment SVM Test', 'Two Segment SVM Validate'};
        COMBINE_OPTIONS = {'Across Channels'};
    end
    
    properties (SetAccess = private)
        operations  % Operations applied to data
    end
    
    properties (Access = private)
        arguments       % Arguments for each operation
        dataSet         % An object of class sstData. Unapplied data.
        procData        % Processed data. An object of sstData class.
        numApldOps      % Number of applied operations.
        dataChangeName  % Name of change in source data.
        availOps        % Operations available
        storedArgs      % A structure with stored volatile args.
                        % Volatile args are the one which are asked during
                        % application of operation
        dSets           % A reference to dataSets class
        dSet            % A reference to corresponding eegData class
    end
    
    methods(Access = protected)
        % Override copyElement method:
        function cpObj = copyElement(obj)
            % Make a shallow copy of all four properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the DeepCp object
            cpObj.procData = copy(obj.procData);
            cpObj.dataSet = copy(obj.dataSet);
            addlistener(cpObj.dSet,'dataSelectionChanged',@cpObj.handleDataSelectionChange);
        end
    end
    methods (Access = public)
        
        function [obj] = eegOperations(data, dSets)
            obj.dataSet = data.getSstData;
            obj.dSet = data;
            if nargin < 2
                obj.dSets = [];
            else
                obj.dSets = dSets;
            end

            % Default properties
            obj.numApldOps = 0;
            obj.availOps = eegOperations.ALL_OPERATIONS;
            obj.procData = data.getSstData;
            addlistener(data,'dataSelectionChanged',@obj.handleDataSelectionChange);
            
            % Stored args
            obj.storedArgs.('sLCentre') = [];
            obj.storedArgs.('eignVect') = [];
            obj.storedArgs.('SVM_Model') = [];
        end
        function handleDataSelectionChange(obj, src, eventData)
            obj.dataChangeName = eventData.changeName;
            obj.numApldOps = 0;
            obj.procData = src.getSstData;
            obj.dataSet = src.getSstData;
            applyAllOperations(obj);
        end
        function explicitHandleDataSelectionChange(obj)
            obj.dataChangeName = 'EXPLICIT_CHANGE';
            obj.numApldOps = 0;
            obj.procData = obj.dSet.getSstData;
            obj.dataSet = obj.dSet.getSstData;
            applyAllOperations(obj);
        end
        function [returnData] = getProcData(obj, apply)
            if(nargin < 2)
                apply = 1;
            end
            if(apply)
                returnData = obj.procData;
            else
                returnData = obj.dataSet;
            end
        end
        function [success] = addOperation (obj)      % Here index refers to ALL_OPERATIONS.
            [s,~] = listdlg('PromptString','Select an operation:', 'SelectionMode','single', 'ListString', ...
                obj.availOps);
            if(isempty(s))
                success = 0;
            else
                
                opName = obj.availOps(s);
                
                index = strcmp(eegOperations.ALL_OPERATIONS, opName);
                indices = 1:length(eegOperations.ALL_OPERATIONS);
                index = indices(index);
                
                args = obj.askArgs(s);
                if(isempty(args))
                    success = 0;
                else
                    if(isempty(obj.operations))
                        obj.operations = eegOperations.ALL_OPERATIONS(index);
                        obj.arguments = {args};
                    else
                        obj.operations = [obj.operations, eegOperations.ALL_OPERATIONS(index)];
                        obj.arguments = [obj.arguments {args}];
                    end
                    success = 1;
                end
            end
            applyAllOperations(obj);
        end
        function rmOperation (obj, index)                   % Here index refers to operations.
            % Operation clearup
            
            selection = 1:length(obj.operations);
            selection = selection ~= index;
            obj.operations = obj.operations(selection);
            obj.arguments = obj.arguments(selection);
            
            obj.procData = copy(obj.dataSet);
            obj.numApldOps = 0;
            applyAllOperations(obj);
        end
    end
    
    methods (Access = private)
        
        function applyAllOperations(obj)
            
            numOperations = length(obj.operations);
            for i=obj.numApldOps + 1 :numOperations
                obj.applyOperation(obj.operations{i}, obj.arguments{i}, obj.procData);
            end
            obj.numApldOps = length(obj.operations);
        end
        function [returnArgs] = askArgs(obj, index)
            switch eegOperations.ALL_OPERATIONS{index}
                case eegOperations.ALL_OPERATIONS{1}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{2}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{3}
                    options = {'constant', 'linear'};
                    [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','single',...
                        'ListString', options, 'ListSize', [160 25]);
                    returnArgs = options(s);
                    % args{1} should be 'linear' or 'constant'
                case eegOperations.ALL_OPERATIONS{4}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{5}
                    dataOut = selectFilterDlg;
                    if(isempty(dataOut))
                        returnArgs = {};
                    else
                        returnArgs = {dataOut.selectedFilter};
                        % args{1} should be a filter object obtained from designfilter.
                    end
                case eegOperations.ALL_OPERATIONS{6}
                    returnArgs = {obj.dataSet.dataRate};
                    % args{1} should be the data rate.
                case eegOperations.ALL_OPERATIONS{7}
                    returnArgs = {'N.R.'};
                    obj.storedArgs.('sLCentre') = [];
                    % chanChange is introduced here to ensure that when
                    % this operation is added after removal, it asks for
                    % argument during operation execution.
                    % No argument required. Which in fact is delayed to
                    % opertion.
                case eegOperations.ALL_OPERATIONS{8}
                    returnArgs = {'N.R.'};
                    obj.storedArgs.('eignVect') = [];
                    % storedArgs is introduced here to ensure that when
                    % this operation is added after removal, it asks for
                    % argument during operation execution.
                    % No argument required. Which in fact is delayed to
                    % opertion.
                case eegOperations.ALL_OPERATIONS{9}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{10}
                    prompt = {'Enter signal time [Si Sf]:','Enter noise time [Ni Nf] (empty = ~[Si Sf]):', 'Per epoch?(1,0):'};
                    dlg_title = 'Input';
                    num_lines = 1;
                    defaultans = {'[]','[]', '1'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        signalInterval = str2num(answer{1}); %% Don't change it to str2double as it is an array
                        noiseInterval = str2num(answer{2});
                        if(length(signalInterval) ~= 2 || signalInterval(2) <= signalInterval(1))
                            errordlg('The format of intervals is invalid.', 'Interval Error', 'modal');
                            returnArgs = {};
                        else
                            
                            returnArgs = {signalInterval; noiseInterval; str2double(answer{3})};
                        end
                    end
                    % args{1} should be a 1 by 2 vector containing signal
                    % time. args{2} should be a 1 by 2 vector containing
                    % noise time. arg{3} should be 1,0
                case eegOperations.ALL_OPERATIONS{11}
                    prompt={'Enter number of stds:'};
                    name = 'Std number';
                    defaultans = {'1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    answer = str2double(answer);
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        if(isnan(answer) || answer <= 0)
                            returnArgs = {};
                        else
                            returnArgs = {answer};
                        end
                    end
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{12}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{13}
                    prompt={'Amplitude >=:', 'Nth peak (0 for all):'};
                    name = 'Detect peak';
                    defaultans = {'1', '1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    answer = str2double(answer);
                    answer(2) = round(answer(2));
                    if(isempty(answer(1)) || isempty(answer(2)))
                        returnArgs = {};
                    else
                        if(isnan(answer(1))  || answer(2) < 0 || isnan(answer(2)))
                            returnArgs = {};
                        else
                            returnArgs = {answer(1), answer(2)};
                        end
                    end
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{14}
                    if(isempty(obj.dSets))
                        uiwait(errordlg('No datasets attached.','Combine Data', 'modal'));
                        
                        returnArgs = {};
                    else
                        dataIn.('dSets') = obj.dSets;
                        
                        dataIn.('availableCombinations') = {'Shift with EMG cues'};
                        dataOut = combineDataDlg(dataIn);
                        if(isempty(dataOut))
                            returnArgs = {};
                        else
                            if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
                                    == obj.dSets.getOperationSuperSet.operationSetNum)
                                uiwait(errordlg('Combining data from the same operation set is not allowed.','Shift Data', 'modal'));
                                returnArgs = {};
                            else
                                dSetNum = dataOut.('dataSetNum');
                                opSetNum = dataOut.('operationSetNum');
                                obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
                                combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
                                if(strcmp(combineData.dataType, sstData.DATA_TYPE_TIME_EVENT))
                                    returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
                                        dataOut.('operationSetNum')};
                                else
                                    uiwait(errordlg('Source data type is not appropriate.','Shift Data', 'modal'));
                                    returnArgs = {};
                                end
                            end
                        end
                    end
                    % args{1} should be a vector of delays.
                case eegOperations.ALL_OPERATIONS{15}
                    returnArgs = {'N.R.'};
                    % No argument required.
                    
                case eegOperations.ALL_OPERATIONS{16}
                    prompt = {'Epoch groups:', 'Group number to select:'};
                    dlg_title = 'Select epochs';
                    num_lines = 1;
                    defaultans = {'2', '1'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    p = str2double(answer{1});
                    q = str2double(answer{2});
                    if(isempty(p) || isempty(q))
                        returnArgs = {};
                    else
                        if(p <= 0 || q > p || q <=0 || isnan(p) || isnan(q))
                            returnArgs = {};
                        else
                            returnArgs = {p, q};
                        end
                    end
                    % args{1} should a vector containing the numbers of
                    % required epochs.
                case eegOperations.ALL_OPERATIONS{17}
                    prompt={'Enter delay for each cue:',};
                    name = 'Shift Cue';
                    defaultans = {'1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        answer = str2num(answer{:});
                        if(isnan(answer))
                            returnArgs = {};
                        else
                            returnArgs = {answer};
                        end
                    end
                    % args{1} should be a vector of delays.
                case eegOperations.ALL_OPERATIONS{18}
                    if(isempty(obj.dSets))
                        uiwait(errordlg('No datasets attached.','Combine Data', 'modal'));
                        
                        returnArgs = {};
                    else
                        dataIn.('dSets') = obj.dSets;
                        
                        dataIn.('availableCombinations') = obj.COMBINE_OPTIONS;
                        dataOut = combineDataDlg(dataIn);
                        if(isempty(dataOut))
                            returnArgs = {};
                        else
                            if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
                                    == obj.dSets.getOperationSuperSet.operationSetNum)
                                uiwait(errordlg('Combining data from the same operation set is not allowed.','Combine Data', 'modal'));
                                returnArgs = {};
                            else
                                returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
                                    dataOut.('operationSetNum')};
                            end
                        end
                    end
                    % args{1} should be a vector of delays.
                case eegOperations.ALL_OPERATIONS{19}
                    prompt = {'Epoch p:', 'Epoch q:'};
                    dlg_title = 'Select resampling ratio p/q';
                    num_lines = 1;
                    defaultans = {'1', '2'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    p = str2double(answer{1});
                    q = str2double(answer{2});
                    if(isempty(p) || isempty(q))
                        returnArgs = {};
                    else
                        if(p <= 0 || q <=0 || isnan(p) || isnan(q))
                            returnArgs = {};
                        else
                            returnArgs = {p, q};
                        end
                    end
                    % args{1} should be p and args{2} should be q.
                case eegOperations.ALL_OPERATIONS{20}
                    prompt={'Delay time:'};
                    name = 'Delay Signal';
                    defaultans = {'1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    answer = str2double(answer);
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        if(isnan(answer))
                            returnArgs = {};
                        else
                            returnArgs = {answer};
                        end
                    end
                    % args{1} should be time in seconds
                case eegOperations.ALL_OPERATIONS{21}
                    prompt={'Enter gain:'};
                    name = 'Signal Gain';
                    defaultans = {'1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    answer = str2double(answer);
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        if(isnan(answer))
                            returnArgs = {};
                        else
                            returnArgs = {answer};
                        end
                    end
                    % args{1} should be gain
                case eegOperations.ALL_OPERATIONS{22}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{23}
                    interval = obj.procData.interval;
                    prompt = {'Segment 1 start:', 'Segment 1 end:','Segment 2 start:','Segment 2 end:',...
                        'Regulization C:','Passes:', sprintf('Data permutation\nRandom=0/Sequential=1/Alternate=2')};
                    dlg_title = 'SVM Train';
                    num_lines = 1;
                    defaultans = {num2str(interval(1)), num2str(interval(2)/2), num2str(interval(2)/2), num2str(interval(2)), '100', '20', '0'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    s1s = str2double(answer(1));
                    s1e = str2double(answer(2));
                    s2s = str2double(answer(3));
                    s2e = str2double(answer(4));
                    c = str2double(answer(5));
                    p = round(str2double(answer(6)));
                    permu = str2double(answer(7));
                    if(isempty(s1s) || isempty(s1e) || isempty(s2s) || isempty(s2e) || isempty(c) || isempty(p) || isempty(permu))
                        returnArgs = {};
                    else
                        if(isnan(s1s) || isnan(s1e) || isnan(s2s) || isnan(s2e) || isnan(c) || isnan(p) || isnan(permu))
                            returnArgs = {};
                        else
                            if(s1s < interval(1) || s2e > interval(2) || c < 0 || p <= 0 ||...
                                    permu < 0 || permu > 2 || s1s >= s1e || s2s >= s2e)
                                returnArgs = {};
                            else
                                if(abs(s1s - s1e) ~= abs(s2s - s2e))
                                    uiwait(errordlg('Both intervals should be equal.','SVM Train', 'modal'));
                                    returnArgs = {};
                                else
                                    returnArgs = {s1s, s1e, s2s, s2e, c, p, permu};
                                end
                            end
                        end
                    end
                    obj.storedArgs.('SVM_Model') = [];
                    % returnArgs = {s1s, s1e, s2s, s2e, c, p, permu};
                case eegOperations.ALL_OPERATIONS{24}
                    if(isempty(obj.dSets))
                        uiwait(errordlg('No datasets attached.','SVM Test', 'modal'));
                        
                        returnArgs = {};
                    else
                        dataIn.('dSets') = obj.dSets;
                        
                        dataIn.('availableCombinations') = {'Load SVM Model'};
                        dataOut = combineDataDlg(dataIn);
                        if(isempty(dataOut))
                            returnArgs = {};
                        else
                            if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
                                    == obj.dSets.getOperationSuperSet.operationSetNum)
                                uiwait(errordlg('Combining data from the same operation set is not allowed.','SVM Test', 'modal'));
                                returnArgs = {};
                            else
                                dSetNum = dataOut.('dataSetNum');
                                opSetNum = dataOut.('operationSetNum');
                                obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
                                combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
                                if(strcmp(combineData.dataType, sstData.DATA_TYPE_PREDICTION))
                                    returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
                                        dataOut.('operationSetNum')};
                                else
                                    uiwait(errordlg('Source data type is not appropriate.','SVM Test', 'modal'));
                                    returnArgs = {};
                                end
                            end
                        end
                    end
                    % args{1} should be a vector of delays.
                case eegOperations.ALL_OPERATIONS{25}
                    if(isempty(obj.dSets))
                        uiwait(errordlg('No datasets attached.','SVM Validate', 'modal'));
                        
                        returnArgs = {};
                    else
                        dataIn.('dSets') = obj.dSets;
                        
                        dataIn.('availableCombinations') = {'Load SVM Model'};
                        dataOut = combineDataDlg(dataIn);
                        if(isempty(dataOut))
                            returnArgs = {};
                        else
                            if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
                                    == obj.dSets.getOperationSuperSet.operationSetNum)
                                uiwait(errordlg('Combining data from the same operation set is not allowed.','SVM Validate', 'modal'));
                                returnArgs = {};
                            else
                                dSetNum = dataOut.('dataSetNum');
                                opSetNum = dataOut.('operationSetNum');
                                obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
                                combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
                                if(strcmp(combineData.dataType, sstData.DATA_TYPE_PREDICTION))
                                    prompt = {'C initial:', 'Step:','C final:'};
                                    dlg_title = 'SVM Validate';
                                    num_lines = 1;
                                    defaultans = {'1', '10', '100'};
                                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                                    cInit = str2double(answer(1));
                                    cStep = str2double(answer(2));
                                    cFinal = str2double(answer(3));
                                    if(isempty(cInit) || isempty(cStep) || isempty(cFinal))
                                        returnArgs = {};
                                    else
                                        if(isnan(cInit) || isnan(cStep) || isnan(cFinal))
                                            returnArgs = {};
                                        else
                                            if(cInit >= s2s || cStep >= cFinal)
                                                returnArgs = {};
                                            else
                                                returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
                                                    dataOut.('operationSetNum'), cInit, cStep, cFinal};
                                            end
                                        end
                                    end
                                else
                                    uiwait(errordlg('Source data type is not appropriate.','SVM Validate', 'modal'));
                                    returnArgs = {};
                                end
                            end
                        end
                    end
                    % args{1} should be a vector of delays.
                otherwise
                    returnArgs = {};
            end
        end
        function applyOperation(obj, operationName, args,  processingData)     
            switch operationName
                case eegOperations.ALL_OPERATIONS{1}
                    channelNums = 1;
                    channelName = 'Mean';
                    obj.procData.setChannelData(mean(processingData.selectedData, 2), channelNums, channelName);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{2}
                    obj.procData.setGrandData(mean(processingData.selectedData, 3));
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{3}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    P = detrend(P, args{1});
                    obj.procData.setSelectedData(eegOperations.shapeSst(P, nT));
                    % args{1} should be 'linear' or 'constant'
                case eegOperations.ALL_OPERATIONS{4}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    P = normc(P);
                    obj.procData.setSelectedData(eegOperations.shapeSst(P, nT));
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{5}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    % Padding 64 samples
                    P = [P(1:64,:);P];
                    P = filter(args{1}, P);
                    P = P(65:end,:);
                    P = eegOperations.shapeSst(P, nT);
                    obj.procData.setSelectedData(P);
                    % args{1} should be a filter object obtained from designfilter.
                case eegOperations.ALL_OPERATIONS{6}
                    P = processingData.selectedData;
                    [m, n, o] = size(P);
                    proc = zeros(floor(m/2) + 1, n, o);
                    for i=1:o
                        [proc(:,:,i), f] = computeFFT(P(:,:,i), args{1});
                    end
                    obj.procData.setFrequencyData(proc, f);
                    % args{1} should be the data rate.
                case eegOperations.ALL_OPERATIONS{7}
                    
                    if(strcmp(obj.dataChangeName, eegData.EVENT_NAME_CHANNELS_CHANGED) || isempty(obj.storedArgs.('sLCentre')))
                        options = processingData.channelNames;
                        [s,~] = listdlg('PromptString','Select centre:', 'SelectionMode','single',...
                            'ListString', options);
                        centre = processingData.channelNums(s);
                        obj.storedArgs.('sLCentre') = centre;
                    else
                        centre = obj.storedArgs.('sLCentre');
                    end
                    filterCoffs = -1 .* ones(processingData.dataSize(2), 1) ./ ((processingData.dataSize(2)) - 1);
                    filterCoffs(centre) = 1;
                    channelName = sprintf('Surrogate of %s',processingData.channelNames{centre});
                    channelNums = 1;
                    obj.procData.setChannelData(spatialFilterSstData(processingData.selectedData, filterCoffs), channelNums, channelName);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{8}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    if(strcmp(obj.dataChangeName, eegData.EVENT_NAME_CHANNELS_CHANGED) || isempty(obj.storedArgs.('eignVect')))
                        try
                            [eignVectors, ~] = pcamat(P',1,2,'gui');
                            
                        catch me
                            disp(me.identifier);
                            eignVectors = eye(size(P));
                        end
                        obj.storedArgs.('eignVect') = eignVectors;
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
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{9}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    proc = fastica(P');
                    proc = proc';
                    channelNums = 1:size(proc, 2);
                    channelNames = cell(size(proc, 2), 1);
                    for i=1:size(proc, 2)
                        channelNames = sprintf('c%s',i);
                    end
                    obj.procData.setChannelData(eegOperations.shapeSst(proc, nT), channelNums, channelNames);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{10}
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
                    
                    % args{1} should be a 1 by 2 vector containing signal
                    % interval. args{2} should be a 1 by 2 vector containing
                    % noise interval. args{3} should be 1,0.
                    
                case eegOperations.ALL_OPERATIONS{11}
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
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{12}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    proc = abs(P);
                    proc = eegOperations.shapeSst(proc, nT);
                    obj.procData.setSelectedData(proc);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{13}
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
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{14}
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

                case eegOperations.ALL_OPERATIONS{15}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    numChannels = processingData.dataSize(2);
                    M=eye(numChannels)-1/numChannels*ones(numChannels);
                    proc= P * M;
                    proc = eegOperations.shapeSst(proc, nT);
                    obj.procData.setSelectedData(proc);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{16}
                    obj.procData.selectEpochGroup(args{1}, args{2});
                    % args{1} should a vector containing the numbers of
                    % required epochs.
                case eegOperations.ALL_OPERATIONS{17}
                    obj.procData.shiftCues(args{1})
                    % args{1} should a vector containing the numbers of
                    % required epochs.
                    
                case eegOperations.ALL_OPERATIONS{18}
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

                    % args{1} should a vector containing the numbers of
                    % required epochs.
                case eegOperations.ALL_OPERATIONS{19}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    p = args{1};
                    q = args{2};
                    proc = resample(P, p, q);
                    proc = eegOperations.shapeSst(proc, nT);
                    obj.procData.setResampledData(proc, processingData.dataRate * p / q);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{20}
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
                    % args{1} should be delay time in seconds.
                case eegOperations.ALL_OPERATIONS{21}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    gain = args{1};
                    proc = P .* gain;
                    proc = eegOperations.shapeSst(proc, nT);
                    obj.procData.setSelectedData(proc);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{22}
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
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{23}
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
                    
                case eegOperations.ALL_OPERATIONS{24}
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
                case eegOperations.ALL_OPERATIONS{25}
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
    end
    methods (Access = public, Static)
        
        function [ P, nT ] = shapeProcessing( S )
            
            [m, n, o] = size(S);
            
            P = zeros(m*o, n);
            
            for i=1:o
                P((m*(i-1))+1:m*i, :) = S(:,:,i);
            end
            nT = o;
        end
        
        function [ S ] = shapeSst( P, nT )  
            [m, n] = size(P);
            rm = m/nT;
            S = zeros(rm, n, nT);
            for i=1:nT
                S(:, :, i) = P((rm*(i-1))+1:rm*i, :);
            end
        end
    end
end

