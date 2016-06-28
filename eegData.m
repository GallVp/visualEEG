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
        folderName      % Name of anchor folder.
        dataSize        % Size of sstData
        extrials        % Excluded trials; 0 means exclude
        subjectNum      % Current selected subject
        sessionNum      % Current selected session
        epochTime       % Time of one epoch
        dataRate        % Data sample rate
        channelNums     % Nums of currently selected channels
        interval        % Interval of data
        currentEpochNum % Currently selected epoch
        epochNums       % Absolute epoch nums in selected data: sstData
        exEpochsOnOff   %Exclude epochs or not
        selectedData
    end
    properties (Access = private)
        ssNfo           % Subject and session info.
        channelNfo      % Information of channels. SrNos and Names
        importMethod    % Import method used.
        beforeIndex
        afterIndex
        dvName
        dvOrient
        evName
        numChannels     % Total number of channels
        sstData         % Data loaded from file
        selectedEpochs  % A logical vector indicating selected epochs
    end
    events
        dataSelectionChanged
    end
    methods
        function obj = eegData
            obj.uiLoad;
        end
    end
    properties(Constant)
        IMPORT_METHOD_BY_TIME = 'BYEPOCHTIME';
        IMPORT_METHOD_BY_EVENT = 'BYEPOCHEVENT';
        IMPORT_METHOD_SIGNAL_MAT_FILES = 'SIGNALMATFILES';
        
        PLOT_TYPE_PLOT = 'PLOT';
        PLOT_TYPE_STEM = 'STEM';
        EVENT_NAME_CHANNELS_CHANGED = 'CHANNELS_CHANGED';
        EVENT_NAME_SUBJECT_CHANGED = 'SUBJECT_CHANGED';
        EVENT_NAME_SESSION_CHANGED = 'SESSION_CHANGED';
        EVENT_NAME_INTERVAL_CHANGED = 'INTERVAL_CHANGED';
        EVENT_NAME_EPOCHS_CHANGED = 'EPOCHS_CHANGED';
    end
    methods (Access = private)
        function uiLoad(obj)
            dataOut = importOptionsDlg;
            if ~isempty(dataOut)
                fname = uigetdir;
                if fname ~=0
                    obj.folderName = fname;
                    obj.dataRate = dataOut.sampleRate;
                    obj.importMethod = dataOut.importMethod;
                    obj.epochTime = dataOut.trialTime;
                    obj.beforeIndex = dataOut.beforeIndex;
                    obj.afterIndex = dataOut.afterIndex;
                    obj.dvName = dataOut.dvName;
                    obj.dvOrient = dataOut.dvOrient;
                    obj.evName = dataOut.evName;
                    try
                        obj.anchorFolder;
                    catch ME
                        if (strcmp(ME.identifier,'eegData:load:noFileFound'))
                            errordlg('Folder does not contain any valid data file(s).','Import Data', 'modal');
                            return
                        elseif(strcmp(ME.identifier,'MATLAB:nonExistentField'))
                            disp(ME);
                            disp('Probable cause: Incorrect variable name used.')
                        else
                            disp(ME);
                            disp('Probable cause: Unknown.')
                        end
                    end
                else
                    ME = MException('eegData:load:noFolder', 'No folder selected.');
                    throw(ME)
                end
            else
                ME = MException('eegData:load:noImportOptions', 'Import options not provided.');
                throw(ME)
            end
        end
        function [ subjectData ] = getSubject(obj, channels)
            subjectData = getSession(obj, channels);
        end
        
        function [ sessionData] = getSession(obj, channels)
            
            ts = 1/obj.dataRate;
            bIndex = obj.beforeIndex / ts;
            aIndex = obj.afterIndex / ts;
            
            D = load(strcat(obj.folderName, sprintf('/sub%02d_sess%02d.mat', obj.subjectNum, obj.sessionNum)));
            if(obj.dvOrient)
                rawEegData = D.(obj.dvName)';
            else
                rawEegData = D.(obj.dvName);
            end
            if(strcmp(obj.importMethod, eegData.IMPORT_METHOD_BY_TIME))
                numTrial = size(rawEegData, 1);
                numTrial = floor(numTrial/obj.dataRate/obj.epochTime);
                sessionData = zeros(obj.epochTime/ts, length(channels),numTrial);
            else
                numTrial = length(D.(obj.evName));
                sessionData = zeros((obj.beforeIndex+obj.afterIndex)/ts, length(channels),numTrial);
            end
            
            for i=1:numTrial
                if(strcmp(obj.importMethod, eegData.IMPORT_METHOD_BY_TIME))
                    sessionData(:,:,i) = getTrialByTrialTime(obj, rawEegData,i,channels, obj.dataRate);
                else
                    indices = [D.(obj.evName)(i)-bIndex D.(obj.evName)(i)+aIndex-1];
                    sessionData(:,:,i) = getTrialByEpochIndex(obj, rawEegData,indices,channels);
                end
            end
        end
        
        function [ trialdata ] = getTrialByTrialTime (obj, rawdata, trialNum, channels,fs)
            
            ts = 1/fs;
            true_intvl = [0 obj.epochTime] + (trialNum - 1) * obj.epochTime;
            
            indices = true_intvl ./ ts;
            
            trialdata = rawdata(indices(1)+1:indices(2),channels);
        end
        
        function [ trialdata ] = getTrialByEpochIndex (obj, rawdata, indices, channels)
            try
                trialdata = rawdata(indices(1):indices(2),channels);
            catch ME
                disp(ME);
                disp('Probable cause: Too large time inteval selected for importing data.')
            end
        end
        
        function validateFolder( obj )
            
            
            folderDir = dir(obj.folderName);
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
            
            obj.ssNfo = dataNfo;
        end
        
        function loadNumChannels(obj)
            if(strcmp(eegData.IMPORT_METHOD_SIGNAL_MAT_FILES, obj.importMethod))
                D = load(strcat(obj.folderName, sprintf('/sub%02d_sess%02d.mat', obj.subjectNum, obj.sessionNum)), sprintf('sub%02d_sess%02d',  obj.subjectNum, obj.sessionNum));
                nChannels = size(D.(sprintf('sub%02d_sess%02d', obj.subjectNum, obj.sessionNum)).values);
                nChannels = nChannels(2); %% This is how Signal exports its files.
            else
                D = load(strcat(obj.folderName, sprintf('/sub%02d_sess%02d.mat', obj.subjectNum, obj.sessionNum)), obj.dvName);
                nChannels = size(D.(obj.dvName));
                nChannels = nChannels(-obj.dvOrient + 2); %% y = -x + 2
            end
            obj.numChannels = nChannels;
        end
        
        function loadChannelNames(obj)
            channelSrNos = [1:obj.numChannels]';
            try
                [~,~,raw] = xlsread(strcat(obj.folderName, '/channel_names.xls'));
                if(sum(cell2mat(raw(:,1)) == channelSrNos) == length(channelSrNos))
                    channelNames = raw(:,2);
                else
                    channelNames = cellstr(num2str(channelSrNos));
                end
            catch ME
                channelNames = cellstr(num2str(channelSrNos));
            end
            %Column 1 contains serial number, column two contains  names of
            % channels.
            obj.channelNfo = cell(1, 2);
            obj.channelNfo{:,1} = [1:obj.numChannels]';
            obj.channelNfo{:,2} = channelNames;
        end
        
        function anchorFolder(obj)
            
            validateFolder(obj);
            
            % Set current selection of subject and session numbers
            lst = cell2mat(obj.ssNfo(:,1));
            subNum = lst(1);
            lst = cell2mat(obj.ssNfo(1, 2));
            sessNum = lst(1);
            
            obj.subjectNum = subNum;
            obj.sessionNum = sessNum;
            
            % Calculate epoch time if required
            if(strcmp(obj.importMethod, obj.IMPORT_METHOD_BY_EVENT))
                obj.epochTime = obj.beforeIndex + obj.afterIndex;
            end
            
            obj.loadNumChannels;
            obj.loadChannelNames;
            obj.loadSubSessFile;
        end
        
        function loadSubSessFile(obj)
            if(strcmp(eegData.IMPORT_METHOD_SIGNAL_MAT_FILES, obj.importMethod))
                D = load(strcat(obj.folderName, sprintf('/sub%02d_sess%02d.mat', obj.subjectNum, obj.sessionNum)),...
                    sprintf('sub%02d_sess%02d', obj.subjectNum, obj.sessionNum));
                obj.sstData = D.(sprintf('sub%02d_sess%02d', obj.subjectNum, obj.sessionNum)).values;
                obj.epochTime = size(obj.sstData, 1);
                obj.epochTime = obj.epochTime / obj.dataRate;
            else
                obj.sstData = getSubject(obj, 1:obj.numChannels);
            end
            
            obj.dataSize = size(obj.sstData);
            
            try
                D = load(strcat(obj.folderName,'/ex_trials.mat'), 'ex_trials');
                obj.extrials = cell2mat(D.ex_trials(cell2mat(D.ex_trials(:,1)) == obj.subjectNum &...
                    cell2mat(D.ex_trials(:,2)) == obj.sessionNum,3));
                if(isempty(obj.extrials))
                    obj.extrials = ones(1, obj.dataSize(3));
                end
            catch me
                disp(me.identifier);
                if(strcmp(me.identifier, 'MATLAB:load:couldNotReadFile'))
                    obj.extrials = ones(1, obj.dataSize(3));
                    ex_trials = {obj.subjectNum, obj.sessionNum, obj.extrials};
                    save(strcat(obj.folderName,'/ex_trials.mat'), 'ex_trials');
                end
            end
            % Default selection of data
            obj.channelNums = 1:obj.numChannels;
            obj.interval = [0 obj.epochTime]; % Display interval starts from 0, actual interval starts from Ts
            obj.currentEpochNum = 1;
            obj.epochNums = 1:obj.dataSize(3);
            obj.exEpochsOnOff = 0;
            obj.selectedData = obj.sstData;
            obj.selectedEpochs = ones(1, obj.dataSize(3)) == 1;
        end
    end
    methods (Access = public)   
        
        function updateTrialExStatus(obj, relativeEpochNum, status)
            absoluteEpochNum = obj.absoluteEpochNum(relativeEpochNum);
            obj.extrials(absoluteEpochNum) = status;
            
            D = load(strcat(obj.folderName,'/ex_trials.mat'), 'ex_trials');
            ext = cell2mat(D.ex_trials(cell2mat(D.ex_trials(:,1))==obj.subjectNum & cell2mat(D.ex_trials(:,2))==obj.sessionNum,3));
            if(isempty(ext))
                ext = obj.extrials;
                ex_trials = [D.ex_trials; {obj.subjectNum, obj.sessionNum, ext}];
            else
                D.ex_trials(cell2mat(D.ex_trials(:,1))==obj.subjectNum & cell2mat(D.ex_trials(:,2))==obj.sessionNum,3) = {obj.extrials};
                ex_trials = D.ex_trials;
            end
            save(strcat(obj.folderName,'/ex_trials.mat'), 'ex_trials');
            
            allEPochNums = 1:size(obj.sstData, 3);
            if(obj.exEpochsOnOff)
                obj.epochNums = allEPochNums(obj.extrials & obj.selectedEpochs);
            else
                obj.epochNums = allEPochNums(obj.selectedEpochs);
            end
            obj.selectedData = obj.sstData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
            obj.dataSize = size(obj.selectedData);
            
            notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_EPOCHS_CHANGED));
        end
        
        function [channelSrNos] = listAllChannelNums(obj)
            channelSrNos = obj.channelNfo{1,1};
        end
        
        function [channelNames] = listAllChannelNames(obj)
            channelNames = obj.channelNfo{1,2};
        end
        
        function [channelNames] = listChannelNames(obj)
            names = obj.listAllChannelNames;
            channelNames = names(obj.channelNums);
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
            eegData.plotSstData({obj.interval(1) + 1/obj.dataRate:1/obj.dataRate:obj.interval(2)}, {obj.selectedData},...
                {sprintf('Sub:%02d Sess:%02d', obj.subjectNum, obj.sessionNum)}, {eegData.PLOT_TYPE_PLOT}, -1, obj.currentEpochNum);
        end
        
        function selectSub(obj,sub)
            % Throws exception eegData:load:noSuchSubject
            if(sum(ismember(obj.listSubjects, sub)))
                obj.subjectNum = sub;
                sessions = obj.listSessions;
                obj.sessionNum = sessions(1);
                obj.loadSubSessFile;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_SUBJECT_CHANGED));
            else
                ME = MException('eegData:load:noSuchSubject', 'This subject number is not available.');
                throw(ME)
            end
        end
        
        function selectSess(obj,sess)
            % Throws exception eegData:load:noSuchSession
            if(sum(ismember(obj.listSessions, sess)))
                obj.sessionNum = sess;
                obj.loadSubSessFile;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_SESSION_CHANGED));
            else
                ME = MException('eegData:load:noSuchSession', 'This session number is not available.');
                throw(ME)
            end
        end
        function selectChannels(obj,channelNums)
            % Throws exception eegData:load:noSuchChannels
            if(sum(ismember(obj.listAllChannelNums, channelNums)) == length(channelNums))
                obj.channelNums = channelNums;
                obj.selectedData = obj.sstData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_CHANNELS_CHANGED));
            else
                ME = MException('eegData:load:noSuchChannels', 'Invalid channels selected.');
                throw(ME)
            end
        end
        function selectChannelsByName(obj,channelNames)
            % Throws exception eegData:load:noSuchChannels
            if(sum(ismember(obj.listAllChannelNames, channelNames)) == length(channelNames))
                nums = obj.listAllChannelNums;
                obj.channelNums = nums(ismember(obj.listAllChannelNames, channelNames));
                obj.selectedData = obj.sstData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_CHANNELS_CHANGED));
            else
                ME = MException('eegData:load:noSuchChannels', 'Invalid channels selected.');
                throw(ME)
            end
        end
        function selectInterval(obj,interval)
            % Throws exception eegData:load:noSuchInterval
            if(length(interval) == 2 && interval(1) < interval(2) && interval(1) >= 0 && interval(2) <= obj.epochTime)
                obj.interval = interval;
                obj.selectedData = obj.sstData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_INTERVAL_CHANGED));
            else
                ME = MException('eegData:load:noSuchInterval', 'Invalid interval selected.');
                throw(ME)
            end
        end
        function excludeEpochs(obj, onOff)
            if(onOff ~= obj.exEpochsOnOff)
                allEPochNums = 1:size(obj.sstData, 3);
                if(onOff)
                    obj.exEpochsOnOff = onOff;
                    obj.epochNums = allEPochNums(obj.extrials & obj.selectedEpochs);
                    
                else
                    obj.epochNums = allEPochNums(obj.selectedEpochs);
                    obj.exEpochsOnOff = onOff;
                end
                obj.selectedData = obj.sstData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                obj.currentEpochNum = 1;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_EPOCHS_CHANGED));
            end
        end
        
        function selectEpochs(obj, relativeEpochNums)
            allEPochNums = 1:size(obj.sstData, 3);
            try
                absoluteEpochNums = obj.absoluteEpochNum(relativeEpochNums);
            catch ME
                disp(ME);
                disp('Invalid epochs selected.');
                return;
            end
            
            if(sum(ismember(obj.epochNums, absoluteEpochNums)) == length(absoluteEpochNums))
                obj.selectedEpochs = ismember(allEPochNums, absoluteEpochNums);
                if(obj.exEpochsOnOff)
                    obj.epochNums = allEPochNums(obj.extrials & obj.selectedEpochs);
                else
                    obj.epochNums = allEPochNums(obj.selectedEpochs);
                end
                obj.selectedData = obj.sstData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                obj.currentEpochNum = 1;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_EPOCHS_CHANGED));
            else
                ME = MException('eegData:load:noSuchEpochs', 'Invalid epochs selected.');
                throw(ME)
            end
        end
        function [indices] = getSelectedIndices(obj)
            indices = (obj.interval(1) + 1/obj.dataRate : 1/obj.dataRate : obj.interval(2)) .* obj.dataRate;
        end
        function [epoch] = getEpoch(obj)
            epoch = obj.selectedData(:,:,obj.currentEpochNum);
        end
        function [answer] = isempty(obj)
            answer = isempty(obj.selectedData);
        end
        function [answer] = isLastEpoch(obj)
            answer = obj.currentEpochNum == obj.dataSize(3);
        end
        function [answer] = isFirstEpoch(obj)
            answer = obj.currentEpochNum == 1;
        end
        function [epochNum] = absoluteEpochNum(obj, relativeEpochNum)
            try
                epochNum = obj.epochNums(relativeEpochNum);
            catch ME
                disp(ME);
                disp('Invalid epochs selected.');
            end
        end
        function [obj] = nextEpoch(obj)
            if(obj.isLastEpoch)
                ME = MException('eegData:select:lastEpoch', 'Current epoch is the last epoch.');
                throw(ME)
            else
                obj.currentEpochNum = obj.currentEpochNum + 1;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_EPOCHS_CHANGED));
            end
        end
        function [obj] = previousEpoch(obj)
            if(obj.isFirstEpoch)
                ME = MException('eegData:select:firstEpoch', 'Current epoch is the first epoch.');
                throw(ME)
            else
                obj.currentEpochNum = obj.currentEpochNum - 1;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_EPOCHS_CHANGED));
            end
        end
    end
    methods (Access = public, Static)
        function [ X, Xcv, Xtest, y, ycv, ytest] = splitData(sstData, intvla, intvlb, dataRate,  trainPer, cvPer, testPer)
            
            
            %loading data
            indicesa = round([intvla(1)+1/dataRate intvla(2)] .* dataRate);
            indicesb = round([intvlb(1)+1/dataRate intvlb(2)] .* dataRate);
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
        function H = plotSstData(abscissa, sstData, titleText, plotType, xAxisLimits, epochNum)
            % Create a figure and axes
            % xAxisLimits = -1 means that this argument is not used
            % sstData, abscicca, titleText and plotType should be m * 1 cell arrays.
            
            switch nargin
                case 4
                    persistant.trialNum = 1;
                    xAxisLimits = -1;
                case 5
                    persistant.trialNum = 1;
                otherwise
                    persistant.trialNum = epochNum;
            end
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

