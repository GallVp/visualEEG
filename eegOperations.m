classdef eegOperations < handle
% Copyright (c) <2016> <Usman Rashid>
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% LICENSE included with this distribution for more information.
    properties (Constant)
        AVAILABLE_OPERATIONS = {'Mean', 'Grand Mean', 'Detrend', 'Normalize', 'Filter', 'FFT', 'Spatial Laplacian', 'PCA', 'FAST ICA', 'Optimal SF', 'Threshold by std.', 'Abs', 'Detect Peak', 'Shift with Cue', 'OSTF '};
    end
    
    properties (SetAccess = private)
        operations  % Operations applied to data
    end
    
    properties (Access = private)
        arguments   % Arguments for each operation
        dataSet     % An object of class eegData.
        procData    % Processed data.
        abscissa    % x-axis data.
        channels    % Selected channels.
        exepochs    % Index of excluded epochs. 1 means include.
        exOnOff     % To exclude or not to exclude the epochs.
        numApldOps  % Number of applied operations.
        dataDomain  % Domain of processed data
        intvl       % Interval for FFT
        chanChange  % Number of channels changed.
        sLCentre    % Centre for spatial laplacian filter.
        eignVect    % Eignvectors computed for PCA.
    end
    
    methods
        function attachDataSet(obj, eegData)
            obj.dataSet = eegData;
            obj.numApldOps = 0;
            obj.chanChange = 1;
        end
        function updateDataInfo(obj, channels, intvl, opsOnOff)
            if(isequal(obj.channels,channels))
                obj.chanChange = 0;
            else
                obj.chanChange = 1;
            end
            obj.channels = channels;
            obj.exOnOff = opsOnOff;
            obj.intvl = intvl;
            obj.procData = [];
            obj.abscissa = [];
            obj.dataDomain = {'None'};
            obj.numApldOps = 0;
            if(obj.exOnOff)
                obj.exepochs = ~obj.dataSet.extrials;
            else
                obj.exepochs = ones(1, length(obj.dataSet.extrials));
                obj.exepochs = obj.exepochs == 1;
            end
        end
        function [returnData, abscissa, dataDomain] = getProcData(obj)
            if(isempty(obj.procData))
                obj.procData = obj.dataSet.sstData(:,obj.channels, obj.exepochs);
                obj.abscissa = 0:1/obj.dataSet.dataRate:obj.dataSet.epochTime;
                obj.dataDomain = {'Time'};
            end
            if (obj.numApldOps == length(obj.operations) - 1)
                applyLastOperation(obj);
            elseif (obj.numApldOps == 0)
                applyAllOperations(obj);
            else
                % Do nothing!!
            end
            returnData = obj.procData;
            abscissa = obj.abscissa;
            dataDomain = obj.dataDomain;
        end
        function [success] = addOperation (obj, index)      % Here index refers to AVAILABLE_OPERATIONS.
            args = obj.askArgs(index);
            if(isempty(args))
                success = 0;
            else
                if(isempty(obj.operations))
                    obj.operations = eegOperations.AVAILABLE_OPERATIONS(index);
                    obj.arguments = {args};
                else
                    obj.operations = [obj.operations, eegOperations.AVAILABLE_OPERATIONS(index)];
                    obj.arguments = [obj.arguments {args}];
                end
                success = 1;
            end
        end
        function rmOperation (obj, index)                   % Here index refers to operations.
            selection = 1:length(obj.operations);
            selection = selection ~= index;
            obj.operations = obj.operations(selection);
            obj.arguments = obj.arguments(selection);
        end
    end
    
    methods (Access = public)
        function applyAllOperations(obj)
            numOperations = length(obj.operations);
            for i=1:numOperations
                [obj.procData, obj.abscissa, obj.dataDomain] = obj.applyOperation(obj.operations{i}, obj.arguments{i}, obj.procData);
            end
            obj.numApldOps = length(obj.operations);
        end
        function applyLastOperation(obj)
            index = length(obj.operations);
            [obj.procData, obj.abscissa, obj.dataDomain] = obj.applyOperation(obj.operations{index}, obj.arguments{index}, obj.procData);
            obj.numApldOps = obj.numApldOps + 1;
        end
        function [returnArgs] = askArgs(obj, index)
            switch eegOperations.AVAILABLE_OPERATIONS{index}
                case eegOperations.AVAILABLE_OPERATIONS{1}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{2}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{3}
                    options = {'constant', 'linear'};
                    [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','single',...
                        'ListString', options, 'ListSize', [160 25]);
                    returnArgs = options(s);
                    % args{1} should be 'linear' or 'constant'
                case eegOperations.AVAILABLE_OPERATIONS{4}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{5}
                    dataOut = selectFilterDlg;
                    if(isempty(dataOut))
                        returnArgs = {};
                    else
                        returnArgs = {dataOut.selectedFilter};
                        % args{1} should be a filter object obtained from designfilter.
                    end
                case eegOperations.AVAILABLE_OPERATIONS{6}
                    returnArgs = {obj.dataSet.dataRate};
                    % args{1} should be the data rate.
                case eegOperations.AVAILABLE_OPERATIONS{7}
                    returnArgs = {'N.R.'};
                    obj.chanChange = 1;
                    % chanChange is introduced here to ensure that when
                    % this operation is added after removal, it asks for
                    % argument during operation execution.
                    % No argument required. Which in fact is delayed to
                    % opertion.
                case eegOperations.AVAILABLE_OPERATIONS{8}
                    returnArgs = {'N.R.'};
                    obj.chanChange = 1;
                    % chanChange is introduced here to ensure that when
                    % this operation is added after removal, it asks for
                    % argument during operation execution.
                    % No argument required. Which in fact is delayed to
                    % opertion.
                case eegOperations.AVAILABLE_OPERATIONS{9}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{10}
                    prompt = {'Enter signal time [Si Sf]:','Enter noise time [Ni Nf]:'};
                    dlg_title = 'Input';
                    num_lines = 1;
                    defaultans = {'[]','[]'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    if(isempty(answer))
                        returnArgs = {};
                    else
                        signalTime = str2num(answer{1}); %% Don't change it to str2double as it is an array
                        noiseTime = str2num(answer{2});
                        if(length(signalTime) ~= 2 || length(noiseTime) ~= 2 || signalTime(2) <= signalTime(1) || noiseTime(2) <= noiseTime(1))
                            errordlg('The format of intervals is invalid.', 'Interval Error', 'modal');
                            returnArgs = {};
                        else
                            
                            returnArgs = {signalTime; noiseTime};
                        end
                    end
                    % args{1} should be a 1 by 2 vector containing signal
                    % time. args{2} should be a 1 by 2 vector containing
                    % noise time.
                case eegOperations.AVAILABLE_OPERATIONS{11}
                    prompt={'Enter number of stds:'};
                    name = 'Std number';
                    defaultans = {'1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    returnArgs = answer;
                    % args{1} should be number of stds to use.
                case eegOperations.AVAILABLE_OPERATIONS{12}
                    returnArgs = {'N.R.'};
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{13}
                    prompt={'Amplitude >=:', 'Nth peak (0 for all):'};
                    name = 'Detect peak';
                    defaultans = {'1', '1'};
                    answer = inputdlg(prompt,name,[1 40],defaultans);
                    returnArgs = answer;
                    % args{1} should be number of stds to use.
                case eegOperations.AVAILABLE_OPERATIONS{14}
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
                otherwise
                    returnArgs = {};
            end
        end
        function [processedData, abscissa, dataDomain] = applyOperation(obj, operationName, args,  processingData)     
            switch operationName
                case eegOperations.AVAILABLE_OPERATIONS{1}
                    processedData = mean(processingData, 2);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{2}
                    processedData = mean(processingData, 3);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{3}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    processedData = detrend(P, args{1});
                    processedData = eegOperations.shapeSst(processedData, nT);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % args{1} should be 'linear' or 'constant'
                case eegOperations.AVAILABLE_OPERATIONS{4}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    processedData = normc(P);
                    processedData = eegOperations.shapeSst(processedData, nT);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{5}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    % Padding 64 samples
                    P = [P(1:64,:);P];
                    processedData = filter(args{1}, P);
                    processedData = processedData(65:end,:);
                    processedData = eegOperations.shapeSst(processedData, nT);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % args{1} should be a filter object obtained from designfilter.
                case eegOperations.AVAILABLE_OPERATIONS{6}
                    indices = (obj.intvl(1) * obj.dataSet.dataRate + 1) : (obj.intvl(2) * obj.dataSet.dataRate);
                    processingData = processingData(indices, :,:);
                    [m, n, o] = size(processingData);
                    processedData = zeros(floor(m/2) + 1, n, o);
                    for i=1:o
                        [processedData(:,:,i), f] = computeFFT(processingData(:,:,i), args{1});
                    end
                    abscissa = f;
                    dataDomain = {'Frequency'};
                    % args{1} should be the data rate.
                case eegOperations.AVAILABLE_OPERATIONS{7}
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
                    processedData = spatialFilterSstData(processingData, filterCoffs);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{8}
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
                    processedData = P * eignVectors;
                    processedData = eegOperations.shapeSst(processedData, nT);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{9}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    processedData = fastica(P');
                    processedData = processedData';
                    processedData = eegOperations.shapeSst(processedData, nT);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{10}
                    signal_intvl = args{1};
                    noise_intvl = args{2};
                    signal_intvl = signal_intvl(1) + 1/obj.dataSet.dataRate:1/obj.dataSet.dataRate:signal_intvl(2);
                    noise_intvl = noise_intvl(1) + 1/obj.dataSet.dataRate:1/obj.dataSet.dataRate:noise_intvl(2);
                    signal_intvl = round(signal_intvl .* obj.dataSet.dataRate);
                    noise_intvl = round(noise_intvl .* obj.dataSet.dataRate);
                    signalData = processingData(signal_intvl,:,:);
                    noiseData = processingData(noise_intvl,:,:);
                    
                    processedData = zeros(size(processingData, 1), 1, size(processingData, 3));
                    
                    for i = 1:size(signalData, 3)
                        w = osf(signalData(:,:,i)', noiseData(:,:,i)');
                        processedData(:,:,i) = spatialFilterSstData(processingData(:,:,i), w);
                    end
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % args{1} should be a 1 by 2 vector containing signal
                    % time. args{2} should be a 1 by 2 vector containing
                    % noise time.
                    
                case eegOperations.AVAILABLE_OPERATIONS{11}
                    numEpochs = size(processingData, 3);
                    numChannels = size(processingData, 2);
                    numStds = str2double(args{1});
                    processedData = zeros(size(processingData));
                    for i=1:numEpochs
                        for j=1:numChannels
                            dataStd = std(processingData(:,j, i));
                            processedData(:,j, i) = processingData(:,j, i) > dataStd * numStds;
                        end
                    end
                    
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % args{1} should be number of stds to use.
                case eegOperations.AVAILABLE_OPERATIONS{12}
                    [P, nT] = eegOperations.shapeProcessing(processingData);
                    processedData = abs(P);
                    processedData = eegOperations.shapeSst(processedData, nT);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % No argument required.
                case eegOperations.AVAILABLE_OPERATIONS{13}
                    numEpochs = size(processingData, 3);
                    numChannels = size(processingData, 2);
                    numSamples = size(processingData, 1);
                    thresh = str2double(args{1});
                    peakNumber = round(str2double(args{2}));
                    processedData = zeros(size(processingData));
                    for i=1:numEpochs
                        for j=1:numChannels
                            pn = 0;
                            for k=1:numSamples
                                if(processingData(k,j,i) >= thresh)
                                    pn = pn +1;
                                    if(peakNumber == 0)
                                        processedData(k,j,i) = 1;
                                        continue;
                                    elseif(peakNumber == pn)
                                        processedData(k,j,i) = 1;
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
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % args{1} should be number of stds to use.
                case eegOperations.AVAILABLE_OPERATIONS{14}
                    numEpochs = size(processingData, 3);
                    cueTime = str2double(args{1});
                    cues = args{2};
                    offset = args{3};
                    processedData = zeros(size(processingData));
                    for i=1:numEpochs
                        ext = cell2mat(cues(cell2mat(cues(:,1))==obj.dataSet.subjectNum & cell2mat(cues(:,2))==obj.dataSet.sessionNum,3));
                        cue = ext(i);
                        n = round((cueTime - cue - offset) * obj.dataSet.dataRate);
                        processedData(:,:, i) = circshift(processingData(:,:,i), n, 1);
                    end
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % args{1} should be number of stds to use.
                otherwise
                    processedData = processingData;
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
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

