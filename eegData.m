classdef eegData < matlab.mixin.Copyable
    
% eegData A class representing eeg data and anchored into a folder.

% Copyright (c) <2016> <Usman Rashid>
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% LICENSE included with this distribution for more information.
    
    properties (SetAccess = private)
        sstData     % Data of selected session for selected subject.
        folderName  % Name of anchor folder.
        dataSize    % Size of sstData
        extrials    % Excluded trials; 1 means exclude
        subjectNum  % Current selected subject
        sessionNum  % Current selected session
        importMethod% Method of importing data
        beforeIndex % Time before index
        afterIndex  % Time after index
        trialTime   % Time of one trial
        numChannels % Total number of channels
        dataRate    % Data sample rate
    end
    
    properties (Access = private)
        ssNfo       % Subject and session info.
        channelNfo  % Information of channels.
    end
    
    properties(Constant)
        IMPORT_METHOD_BY_TIME = 'BYTRIALTIME';
        IMPORT_METHOD_BY_INDEX = 'BYEPOCHINDEX';
        IMPORT_METHOD_EMG_CUE_FILES = 'EMGCUEFILES';
        
        PLOT_TYPE_PLOT = 'PLOT';
        PLOT_TYPE_STEM = 'STEM';
    end
    
    methods (Access = private, Static)
        function [ subjectData ] = getSubject(folderName, subNum, sessions, channels, fs, trialTime, beforeIndex, afterIndex, importMethod)
            for i=1:length(sessions)
                subjectData(:,:,:,i) = eegData.getSession(folderName, subNum,sessions(i),channels, fs, trialTime, beforeIndex, afterIndex, importMethod);
            end
        end
        
        function [ sessionData] = getSession(folderName, subNum, sessNum, channels, fs, trialTime, beforeIndex, afterIndex, importMethod)
            
            ts = 1/fs;
            bIndex = beforeIndex / ts;
            aIndex = afterIndex / ts;
            
            D = load(strcat(folderName, sprintf('/sub%02d_sess%02d.mat', subNum, sessNum)));
            rawEegData = D.EEGdata';
            Epoch_start = D.Epoch_start;
            if(strcmp(importMethod, 'BYTRIALTIME'))
                numTrial = size(rawEegData);
                numTrial = floor(numTrial(1)/fs/trialTime);
                sessionData = zeros(trialTime/ts, length(channels),numTrial);
            else
                numTrial = length(Epoch_start);
                sessionData = zeros((beforeIndex+afterIndex)/ts, length(channels),numTrial);
            end
            
            for i=1:numTrial
                if(strcmp(importMethod, 'BYTRIALTIME'))
                    sessionData(:,:,i) = eegData.getTrialByTrialTime(rawEegData,i,channels, fs, trialTime);
                else
                    indices = [Epoch_start(i)-bIndex Epoch_start(i)+aIndex-1];
                    sessionData(:,:,i) = eegData.getTrialByEpochIndex(rawEegData,indices,channels);
                end
            end
        end
        
        function [ trialdata ] = getTrialByTrialTime (rawdata, trialNum, channels,fs, trialTime)
            
            ts = 1/fs;
            true_intvl = [0 trialTime] + (trialNum - 1) * trialTime;
            
            indices = true_intvl ./ ts;
            
            trialdata = rawdata(indices(1)+1:indices(2),channels);
        end
        
        function [ trialdata ] = getTrialByEpochIndex (rawdata, indices, channels)
            
            trialdata = rawdata(indices(1):indices(2),channels);
        end
        
        function [ dataNfo ] = validateFolder( folderName )
            
            
            folderDir = dir(folderName);
            numContents = length(folderDir);
            
            j=1;
            for i=1:numContents
                if(~folderDir(i).isdir)
                    fileNames{j} = folderDir(i).name;
                    j = j + 1;
                end
            end
            
            
            fileData = regexp(fileNames, '^sub(\d+)_sess(\d+).mat$','tokens', 'once');
            
            
            fileData = fileData';
            fileData = vertcat(fileData{:});
            fileData = cellfun(@str2num,fileData);
            if(isempty(fileData))
                ME = MException('eegData:load:noFileFound', 'The folder does not contain any valid data file.');
                throw(ME)
            end
            subjects = unique(fileData(:,1));
            
            dataNfo = cell(length(subjects), 2);
            
            for i=1:length(subjects)
                dataNfo{i,1} = subjects(i);
                dataNfo{i,2} = [fileData(fileData(:,1)==subjects(i),2)];
            end
        end
        
        function [ nChannels ] = getNumChannels( folderName, importMethod, subNum, sessNum)
            if(strcmp(eegData.IMPORT_METHOD_EMG_CUE_FILES, importMethod))
                D = load(strcat(folderName, sprintf('/sub%02d_sess%02d.mat', subNum, sessNum)), sprintf('sub%02d_sess%02d', subNum, sessNum));
                nChannels = size(D.(sprintf('sub%02d_sess%02d', subNum, sessNum)).values);
                nChannels = nChannels(2);
            else
                D = load(strcat(folderName, sprintf('/sub%02d_sess%02d.mat', subNum, sessNum)), 'EEGdata');
                nChannels = size(D.EEGdata);
                nChannels = nChannels(1);
            end
        end
        
        function [ channelNames ] = loadChannelNames(folderName, channelSrNos)
            try
                [~,~,raw] = xlsread(strcat(folderName, '/channel_names.xls'));
                if(sum(cell2mat(raw(:,1)) == channelSrNos) == length(channelSrNos))
                    channelNames = raw(:,2);
                else
                    channelNames = cellstr(num2str(channelSrNos));
                end
            catch ME
                channelNames = cellstr(num2str(channelSrNos));
            end
        end
    end
    
    methods
        function folderName = get.folderName(obj)
            folderName = obj.folderName;
        end
    end
    
    methods (Access = public)
        function anchorFolder(obj, folderName, dataRate, importMethod, trialTime, beforeIndex, afterIndex)
            % Throws exception eegData:load:noFileFound
            obj.folderName = folderName;
            
            obj.ssNfo = eegData.validateFolder(folderName);
            
            
            lst = cell2mat(obj.ssNfo(:,1));
            subNum = lst(1);
            lst = cell2mat(obj.ssNfo(1, 2));
            sessNum = lst(1);
            
            obj.dataRate = dataRate;
            obj.importMethod = importMethod;
            
            obj.beforeIndex = beforeIndex;
            obj.afterIndex = afterIndex;
            
            if(strcmp(importMethod, obj.IMPORT_METHOD_BY_TIME))
                obj.trialTime = trialTime;
            elseif(strcmp(importMethod, obj.IMPORT_METHOD_BY_INDEX))
                obj.trialTime = beforeIndex + afterIndex;
            else
                %do nothing!! EMG cue files are already in good shape.
                %Caution!!!: obj.trailTime will be updated in the loadDdata
                %method.
            end
            
            obj.numChannels = eegData.getNumChannels(obj.folderName, importMethod, subNum, sessNum);
            
            %Column 1 contains serial number, column two contains  names of
            % channels.
            obj.channelNfo = cell(1, 2);
            obj.channelNfo{:,1} = [1:obj.numChannels]';
            obj.channelNfo{:,2} = eegData.loadChannelNames(folderName, [1:obj.numChannels]');
            
            loadData(obj, subNum, sessNum);
            
        end
        
        function loadData(obj, subNum, sessNum)
            % Throws exception eegData:load:noAnchorFolder
            
            if(isempty(obj.folderName))
                throw(MException('eegData:load:noAnchorFolder', 'anchorFolder should be called first.'));
            end
            
            obj.subjectNum = subNum;
            obj.sessionNum = sessNum;
            
            if(strcmp(eegData.IMPORT_METHOD_EMG_CUE_FILES, obj.importMethod))
                D = load(strcat(obj.folderName, sprintf('/sub%02d_sess%02d.mat', subNum, sessNum)), sprintf('sub%02d_sess%02d', subNum, sessNum));
                obj.sstData = D.(sprintf('sub%02d_sess%02d', subNum, sessNum)).values;
                obj.trialTime = size(obj.sstData, 1);
                obj.trialTime = obj.trialTime / obj.dataRate;
            else
                obj.sstData = eegData.getSubject(obj.folderName, obj.subjectNum, obj.sessionNum,...
                1:obj.numChannels, obj.dataRate, obj.trialTime,...
                obj.beforeIndex, obj.afterIndex, obj.importMethod);
            end
            
            obj.dataSize = size(obj.sstData);
            
            try
                D = load(strcat(obj.folderName,'/ex_trials.mat'), 'mydata');
                obj.extrials = cell2mat(D.mydata(cell2mat(D.mydata(:,1)) == obj.subjectNum & cell2mat(D.mydata(:,2)) == obj.sessionNum,3));
                if(isempty(obj.extrials))
                    obj.extrials = zeros(1, obj.dataSize(3));
                end
            catch me
                disp(me.identifier);
                if(strcmp(me.identifier, 'MATLAB:load:couldNotReadFile'))
                    obj.extrials = zeros(1, obj.dataSize(3));
                    mydata = {obj.subjectNum, obj.sessionNum, obj.extrials};
                    save(strcat(obj.folderName,'/ex_trials.mat'), 'mydata');
                end
            end
        end
        
        function updateTrialExStatus(obj, trialNum, status)
            obj.extrials(trialNum) = status;
            
            D = load(strcat(obj.folderName,'/ex_trials.mat'), 'mydata');
            ext = cell2mat(D.mydata(cell2mat(D.mydata(:,1))==obj.subjectNum & cell2mat(D.mydata(:,2))==obj.sessionNum,3));
            if(isempty(ext))
                ext = obj.extrials;
                mydata = [D.mydata; {obj.subjectNum, obj.sessionNum, ext}];
            else
                D.mydata(cell2mat(D.mydata(:,1))==obj.subjectNum & cell2mat(D.mydata(:,2))==obj.sessionNum,3) = {obj.extrials};
                mydata = D.mydata;
            end
            save(strcat(obj.folderName,'/ex_trials.mat'), 'mydata');
        end
        
        function [channelSrNos] = listChannels(obj)
            channelSrNos = obj.channelNfo{1,1};
        end
        
        function [channelNames] = listChannelNames(obj)
            channelNames = obj.channelNfo{1,2};
        end
        
        function [subjects] = listSubjects(obj)
            subjects = cell2mat(obj.ssNfo(:,1));
        end
        
        function [sessions] = listSessions(obj, subNum)
            if nargin < 2
                sessions = obj.ssNfo{cell2mat(obj.ssNfo(:,1)) == obj.subjectNum,2};
            else
                sessions = obj.ssNfo{cell2mat(obj.ssNfo(:,1)) == subNum,2};
            end
        end
        
        function plotData(obj)
            eegData.plotSstData({1/obj.dataRate:1/obj.dataRate:obj.trialTime}, {obj.sstData}, {sprintf('Sub:%02d Sess:%02d',...
                obj.subjectNum, obj.sessionNum)}, {eegData.PLOT_TYPE_PLOT}, -1);
        end
        
    end
    methods (Access = public, Static)
        function [ X, Xcv, Xtest, y, ycv, ytest] = splitData(sstData, intvla, intvlb, dataRate,  trainPer, cvPer, testPer)
            
            
            %loading data
            indicesa = [intvla(1)+1/dataRate intvla(2)] .* dataRate;
            indicesb = [intvlb(1)+1/dataRate intvlb(2)] .* dataRate;
            subjectData1 = sstData(indicesa(1):indicesa(2),:,:,:);
            subjectData2 = sstData(indicesb(1):indicesb(2),:,:,:);
            
            
            subjectData = cat(3,subjectData1,subjectData2);
            
            
            [m, n, o, p] = size(subjectData);
            
            %Dimension Description
            %m=samples
            %n=channels
            %o=trials
            %p=sessions
            
            
            X = zeros(o*p,m*n);
            for j=1:p
                for k=1:o
                    temp = subjectData(:,:,k,j);
                    X(j*k,:) = temp(:);
                end
            end
            
            total_examples = o*p;
            y = [zeros(total_examples/2,1); ones(total_examples/2,1)];
            
            
            % Taking a random permutation of X and y.
            %P = randperm(total_examples);
            
            P = [1:total_examples/2; total_examples/2+1:total_examples];
            P = P(:);
            
            X_y = [X y];
            
            X_y = X_y(P,:);
            
            X = X_y(:,1:end-1);
            y = X_y(:,end);
            
            %Dividing the feature matrix
            
            train_samples = floor(total_examples * trainPer / 100);
            cv_samples = floor(total_examples * cvPer / 100);
            test_samples = floor(total_examples * testPer / 100);
            
            Xtest = X(train_samples+cv_samples + 1:end,:);
            Xcv = X(train_samples+1:train_samples+cv_samples,:);
            X = X(1:train_samples,:);
            
            
            % Labels
            
            ytest = y(train_samples+cv_samples + 1:end);
            ycv = y(train_samples+1:train_samples+cv_samples);
            y = y(1:train_samples);
        end
        function [ X, Xcv, Xtest] = splitDataMF(sstData, tIntvl, roiIntvl, dataRate,  trainPer, cvPer, testPer)
            
            % queueTime = -1 means that the movement is unqueued.
            
            %loading data
            indicesT = round([tIntvl(1)+1/dataRate tIntvl(2)] .* dataRate);
            indicesR = round([roiIntvl(1)+1/dataRate roiIntvl(2)] .* dataRate);
            
            total_trials = size(sstData, 3);
            
            train_trials = floor(total_trials * trainPer / 100);
            cv_trials = floor(total_trials * cvPer / 100);
            test_samples = floor(total_trials * testPer / 100);
            
            X = sstData(indicesT(1):indicesT(2),:,1:train_trials);
            Xcv = sstData(indicesR(1):indicesR(2),:,train_trials+1:train_trials+cv_trials);
            Xtest = sstData(indicesR(1):indicesR(2),:, train_trials+cv_trials + 1:end);
        end
        function H = plotSstData(abscissa, sstData, titleText, plotType, xAxisLimits)
            % Create a figure and axes
            % xAxisLimits = -1 means that this argument is not used
            % sstData, abscicca, titleText and plotType should be m * 1 cell arrays.
            
            persistant.trialNum = 1;
            persistant.totalEpochs = size(sstData{1}, 3);
            persistant.numDats = size(sstData, 1);
            
            
            H = figure('Visible','off', 'Units', 'pixels');
            enlargeFactor = 50;
            H.Position(4) = H.Position(4) + enlargeFactor;
            
            % Create push button
            btnNext = uicontrol('Style', 'pushbutton', 'String', 'Next',...
                'Position', [300 20 75 20],...
                'Callback', @next);
            
            btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
                'Position', [200 20 75 20],...
                'Callback', @previous);
            
            
            % Add a text uicontrol.
            txtEpochInfo = uicontrol('Style','text',...
                'Position',[75 17 120 20]);
            
            updateView
            
            % Make figure visble after adding all components
            H.Visible = 'on';
            % This code uses dot notation to set properties.
            % Dot notation runs in R2014b and later.
            % For R2014a and earlier: set(f,'Visible','on');
            
            function next(source,callbackdata)
                persistant.trialNum = persistant.trialNum + 1;
                updateView
            end
            
            function previous(source,callbackdata)
                persistant.trialNum = persistant.trialNum - 1;
                updateView
            end
            
            function updateView
                for i=1:persistant.numDats
                    ax = subplot(persistant.numDats, 1, i, 'Units', 'pixels');
                    
                    if(strcmp(plotType{i}, eegData.PLOT_TYPE_PLOT))
                        dat = sstData{i};
                        plot(abscissa{i}, dat(:,:,persistant.trialNum), 'LineWidth', 2)
                    else
                        dat = sstData{i};
                        stem(abscissa{i}, dat(:,:,persistant.trialNum), 'LineWidth', 2)
                    end
                    
                    xlabel('Time (s)')
                    ylabel('Amplitude')
                    title(titleText{i})
                    
                    if(xAxisLimits ~= -1)
                        axL = axis;
                        axL = [xAxisLimits(1) xAxisLimits(2) axL(3) axL(4)];
                        axis(axL);
                    end
                    pos = get(ax, 'Position');
                    pos(2) = pos(2) + enlargeFactor / 2;
                    pos(4) = pos(4) - enlargeFactor / 3;
                    set(ax, 'Position', pos);
                end
                
                if persistant.trialNum == persistant.totalEpochs
                    set(btnNext, 'Enable', 'Off');
                else
                    set(btnNext, 'Enable', 'On');
                end
                if persistant.trialNum == 1
                    set(btnPrevious, 'Enable', 'Off');
                else
                    set(btnPrevious, 'Enable', 'On');
                end
                set(txtEpochInfo, 'String', sprintf('Epoch : %d/%d', persistant.trialNum, persistant.totalEpochs))
            end
        end
    end
end

