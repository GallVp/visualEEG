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
            'PCA', 'FAST ICA', 'Optimal SF', 'Threshold by std.', 'Abs', 'Detect Peak', 'Shift with Cue', 'OSTF', 'Remove Common Mode', 'Group Epochs'};
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
    end
    
    methods(Access = protected)
        % Override copyElement method:
        function cpObj = copyElement(obj)
            % Make a shallow copy of all four properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the DeepCp object
            cpObj.procData = copy(obj.procData);
            cpObj.dataSet = copy(obj.dataSet);
        end
    end
    methods (Access = public)
        
        function [obj] = eegOperations(data)
            obj.dataSet = data.getSstData;
            
            % Default properties
            obj.numApldOps = 0;
            obj.availOps = eegOperations.ALL_OPERATIONS;
            obj.procData = data.getSstData;
            addlistener(data,'dataSelectionChanged',@obj.handleDataSelectionChange);
            
        end
        function handleDataSelectionChange(obj, src, eventData)
            obj.dataChangeName = eventData.changeName;
            obj.numApldOps = 0;
            obj.procData = src.getSstData;
            obj.dataSet = src.getSstData;
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
            opName = obj.operations(index);
            
            if(strcmp(opName, eegOperations.ALL_OPERATIONS(17)))
                obj.availOps = eegOperations.ALL_OPERATIONS;
            end
            
            
            selection = 1:length(obj.operations);
            selection = selection ~= index;
            obj.operations = obj.operations(selection);
            obj.arguments = obj.arguments(selection);
            
            obj.procData = copy(obj.dataSet);
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
                    obj.chanChange = 1;
                    % chanChange is introduced here to ensure that when
                    % this operation is added after removal, it asks for
                    % argument during operation execution.
                    % No argument required. Which in fact is delayed to
                    % opertion.
                case eegOperations.ALL_OPERATIONS{8}
                    returnArgs = {'N.R.'};
                    obj.chanChange = 1;
                    % chanChange is introduced here to ensure that when
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
                        epochs = str2num(answer{1}); %% Don't change it to str2double as it is an array
                        noiseTime = str2num(answer{2});
                        if(length(epochs) ~= 2 || epochs(2) <= epochs(1))
                            errordlg('The format of intervals is invalid.', 'Interval Error', 'modal');
                            returnArgs = {};
                        else
                            
                            returnArgs = {epochs; noiseTime; str2num(answer{3})};
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
                    returnArgs = answer;
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{12}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{13}
                    prompt={'Amplitude >=:', 'Nth peak (0 for all):'};
                    name = 'Detect peak';
                    defaultans = {'1', '1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    returnArgs = answer;
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{14}
                    prompt={'Cue Time:', 'Offset:'};
                    name = 'Cue timing';
                    defaultans = {'1', '1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        cueTime = answer{1};
                        [filename, pathname] = ...
                            uigetfile({'*.mat'},'Select Emg cues file');
                        
                        if(isempty(filename))
                            returnArgs = {};
                        else
                            cueFile = load(strcat(pathname, '/', filename),'cues');
                            returnArgs = {cueTime, cueFile.cues, answer{2}};
                        end
                    end
                    % args{1} should be the cueTime, args{2} should be the emg cues cell array.
                case eegOperations.ALL_OPERATIONS{16}
                    returnArgs = {'N.R.'};
                    % No argument required.
                    
                case eegOperations.ALL_OPERATIONS{17}
                    prompt = {'Enter total epoch groups:', 'Enter group number to select:'};
                    dlg_title = 'Select epochs';
                    num_lines = 1;
                    defaultans = {'2', '1'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        e_start = str2double(answer{1});
                        e_end = str2double(answer{2});
                        if(~isnan(e_start) && ~isnan(e_end))
                            returnArgs = {e_start, e_end};
                        else
                            returnArgs = {};
                        end
                    end
                    % args{1} should a vector containing the numbers of
                    % required epochs.
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
                    epochNums = 1;
                    obj.procData.setEpochData(mean(processingData.selectedData, 3), epochNums);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{3}
                    [P, nT] = eegOperations.shapeProcessing(processingData.selectedData);
                    P = detrend(P, args{1});
                    obj.procData.setSelectedData(eegOperations.shapeSst(P, nT));
                    % args{1} should be 'linear' or 'constant'
                case eegOperations.ALL_OPERATIONS{4}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    obj.procData = normc(P);
                    obj.procData = eegOperations.shapeSst(obj.procData, nT);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{5}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    % Padding 64 samples
                    P = [P(1:64,:);P];
                    obj.procData = filter(args{1}, P);
                    obj.procData = obj.procData(65:end,:);
                    obj.procData = eegOperations.shapeSst(obj.procData, nT);
                    % args{1} should be a filter object obtained from designfilter.
                case eegOperations.ALL_OPERATIONS{6}
                    indices = obj.dataSet.getSelectedIndices;
                    processingData = processingData(indices, :,:);
                    [m, n, o] = size(processingData);
                    obj.procData = zeros(floor(m/2) + 1, n, o);
                    for i=1:o
                        [obj.procData(:,:,i), f] = computeFFT(processingData(:,:,i), args{1});
                    end
                    obj.abscissa = f;
                    obj.dataDomain = {'Frequency'};
                    % args{1} should be the data rate.
                case eegOperations.ALL_OPERATIONS{7}
                    if(obj.chanChange)
                        options = cellstr(num2str(obj.channels'))';
                        [s,~] = listdlg('PromptString','Select centre:', 'SelectionMode','single',...
                            'ListString', options);
                        centre = str2double(options(s));
                        obj.sLCentre = centre;
                    else
                        centre = obj.sLCentre;
                    end
                    filterCoffs = -1 .* ones(length(obj.channels), 1) ./ (length(obj.channels) - 1);
                    filterCoffs(centre) = 1;
                    obj.procData = spatialFilterSstData(processingData, filterCoffs);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{8}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    if(obj.chanChange)
                        try
                            [eignVectors, ~] = pcamat(P',1,2,'gui');
                            
                        catch me
                            disp(me.identifier);
                            eignVectors = eye(size(P));
                        end
                        obj.eignVect = eignVectors;
                    else
                        eignVectors = obj.eignVect;
                    end
                    obj.procData = P * eignVectors;
                    obj.procData = eegOperations.shapeSst(obj.procData, nT);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{9}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    obj.procData = fastica(P');
                    obj.procData = obj.procData';
                    obj.procData = eegOperations.shapeSst(obj.procData, nT);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{10}
                    signal_intvl = args{1};
                    if(~isempty(args{2}))
                        noise_intvl = args{2};
                        noise_intvl = noise_intvl(1) + 1/obj.dataSet.dataRate:1/obj.dataSet.dataRate:noise_intvl(2);
                    else
                        noise_intvl = [0 signal_intvl(1) signal_intvl(2) obj.dataSet.epochTime];
                        noise_intvl = [noise_intvl(1) + 1/obj.dataSet.dataRate:1/obj.dataSet.dataRate:noise_intvl(2)...
                            noise_intvl(3) + 1/obj.dataSet.dataRate:1/obj.dataSet.dataRate:noise_intvl(4)];
                    end
                    signal_intvl = signal_intvl(1) + 1/obj.dataSet.dataRate:1/obj.dataSet.dataRate:signal_intvl(2);
                    
                    signal_intvl = round(signal_intvl .* obj.dataSet.dataRate);
                    noise_intvl = round(noise_intvl .* obj.dataSet.dataRate);
                    signalData = processingData(signal_intvl,:,:);
                    noiseData = processingData(noise_intvl,:,:);
                    
                    if(args{3})
                        obj.procData = zeros(size(processingData, 1), 1, size(processingData, 3));
                        
                        for i = 1:size(signalData, 3)
                            w = osf(signalData(:,:,i)', noiseData(:,:,i)');
                            obj.procData(:,:,i) = spatialFilterSstData(processingData(:,:,i), w);
                        end
                    else
                        [signalData, ~] = eegOperations.shapeProcessing(signalData);
                        [noiseData, ~] = eegOperations.shapeProcessing(noiseData);
                        w = osf(signalData', noiseData');
                        [P, nT] = eegOperations.shapeProcessing(processingData);
                        obj.procData =  P * w;
                        obj.procData = eegOperations.shapeSst(obj.procData, nT);
                    end
                    % args{1} should be a 1 by 2 vector containing signal
                    % time. args{2} should be a 1 by 2 vector containing
                    % noise time. args{3} should be 1,0.
                    
                case eegOperations.ALL_OPERATIONS{11}
                    numEpochs = size(processingData, 3);
                    numChannels = size(processingData, 2);
                    numStds = str2double(args{1});
                    obj.procData = zeros(size(processingData));
                    for i=1:numEpochs
                        for j=1:numChannels
                            dataStd = std(processingData(:,j, i));
                            obj.procData(:,j, i) = processingData(:,j, i) > dataStd * numStds;
                        end
                    end
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{12}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    obj.procData = abs(P);
                    obj.procData = eegOperations.shapeSst(obj.procData, nT);
                    % No argument required.
                case eegOperations.ALL_OPERATIONS{13}
                    numEpochs = size(processingData, 3);
                    numChannels = size(processingData, 2);
                    numSamples = size(processingData, 1);
                    thresh = str2double(args{1});
                    peakNumber = round(str2double(args{2}));
                    obj.procData = zeros(size(processingData));
                    for i=1:numEpochs
                        for j=1:numChannels
                            pn = 0;
                            for k=1:numSamples
                                if(processingData(k,j,i) >= thresh)
                                    pn = pn +1;
                                    if(peakNumber == 0)
                                        obj.procData(k,j,i) = 1;
                                        continue;
                                    elseif(peakNumber == pn)
                                        obj.procData(k,j,i) = 1;
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
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{14}
                    numEpochs = size(processingData, 3);
                    cueTime = str2double(args{1});
                    cues = args{2};
                    offset = args{3};
                    obj.procData = zeros(size(processingData));
                    for i=1:numEpochs
                        ext = cell2mat(cues(cell2mat(cues(:,1))==obj.dataSet.subjectNum & cell2mat(cues(:,2))==obj.dataSet.sessionNum,3));
                        cue = ext(i);
                        n = round((cueTime - cue - offset) * obj.dataSet.dataRate);
                        obj.procData(:,:, i) = circshift(processingData(:,:,i), n, 1);
                    end
                    % args{1} should be number of stds to use.
                case eegOperations.ALL_OPERATIONS{16}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    N_ch = size(P, 2);
                    M=eye(N_ch)-1/N_ch*ones(N_ch);
                    obj.procData= P * M;
                    obj.procData = eegOperations.shapeSst(obj.procData, nT);
                    % No argument required.
                    
                case eegOperations.ALL_OPERATIONS{17}
                    numEpochs = round(size(processingData,3) / args{1});
                    groupNum = args{2};
                    epochs = numEpochs * (groupNum - 1) + 1 : numEpochs * groupNum;
                    epochs = epochs(epochs <= size(processingData,3));
                    obj.procData = processingData(:,:,epochs);
                    obj.procEpochs = obj.procEpochs(epochs);
                    opsNum = ones(1,length(eegOperations.ALL_OPERATIONS));
                    opsNum(17) = 0;
                    obj.availOps = eegOperations.ALL_OPERATIONS(opsNum == 1);
                    % args{1} should a vector containing the numbers of
                    % required epochs.
                otherwise
                    obj.procData = processingData;
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

