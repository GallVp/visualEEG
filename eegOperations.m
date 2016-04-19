classdef eegOperations < handle
% Copyright (c) <2016> <Usman Rashid>
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% LICENSE included with this distribution for more information.
    properties (Constant)
        AVAILABLE_OPERATIONS = {'Mean', 'Grand Mean', 'Detrend', 'Normalize', 'Filter', 'FFT', 'Spatial Laplacian', 'PCA', 'FAST ICA', 'Optimal SF'};
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
                obj.abscissa = 0:1/obj.dataSet.dataRate:obj.dataSet.trialTime;
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
    
    methods (Access = private)
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
                    signalTime = str2num(answer{1});
                    noiseTime = str2num(answer{2});
                    if(length(signalTime) ~= 2 || length(noiseTime) ~= 2 || signalTime(2) <= signalTime(1) || noiseTime(2) <= noiseTime(1))
                        errordlg('The format of intervals is invalid.', 'Interval Error', 'modal');
                        returnArgs = {};
                    else
                        if(abs(signalTime(2) - signalTime(1)) ~= abs(noiseTime(2) - noiseTime(1)))
                            errordlg('The intervals should be equal.', 'Interval Error', 'modal');
                            returnArgs = {};
                        else
                            returnArgs = {signalTime; noiseTime};
                        end
                    end
                    % args{1} should be a 1 by 2 vector containing signal
                    % time. args{2} should be a 1 by 2 vector containing
                    % noise time.
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
                    
                    [signalData, ~] = eegOperations.shapeProcessing(signalData);
                    [noiseData, nT] = eegOperations.shapeProcessing(noiseData);
                    w = osf(signalData', noiseData');
                    
                    processedData = spatialFilterSstData(processingData, w);
                    abscissa = obj.abscissa;
                    dataDomain = obj.dataDomain;
                    % args{1} should be a 1 by 2 vector containing signal
                    % time. args{2} should be a 1 by 2 vector containing
                    % noise time.
                otherwise
                    processedData = processingData;
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

