classdef eegData < sstData
    
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
        extrials        % Excluded trials; 0 means exclude
        epochTime       % Time of one epoch
        exEpochsOnOff   %Exclude epochs or not
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
        fileData         % Data loaded from file
        selectedEpochs  % A logical vector indicating selected epochs
    end
    events
        dataSelectionChanged
    end
    methods
        function obj = eegData
            obj.uiLoad;
        end
        function data = getSstData(obj)
            data = sstData;
            currentEpochNum = 1;
            abscissa = obj.interval(1) + 1/obj.dataRate:1/obj.dataRate:obj.interval(2);
            dataType = sstData.DATA_TYPE_TIME_SERIES;
            data.setData(obj.selectedData, obj.subjectNum, obj.sessionNum, obj.dataRate, obj.channelNums, obj.listChannelNames, obj.interval,...
                obj.epochNums, currentEpochNum, abscissa, dataType)
        end
    end
    properties(Constant)
        IMPORT_METHOD_BY_TIME = 'BYEPOCHTIME';
        IMPORT_METHOD_BY_EVENT = 'BYEPOCHEVENT';
        IMPORT_METHOD_SIGNAL_MAT_FILES = 'SIGNALMATFILES';

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
            
            
            obj.fileData = regexp(fileNames, '^sub(\d+)_sess(\d+).mat$','tokens', 'once');
            
            
            obj.fileData = obj.fileData';
            obj.fileData = vertcat(obj.fileData{:});
            obj.fileData = cellfun(@str2num,obj.fileData);
            if(isempty(obj.fileData))
                ME = MException('eegData:load:noFileFound', 'The folder does not contain any valid data file.');
                throw(ME)
            end
            subjects = unique(obj.fileData(:,1));
            
            dataNfo = cell(length(subjects), 2);
            
            for i=1:length(subjects)
                dataNfo{i,1} = subjects(i);
                dataNfo{i,2} = [obj.fileData(obj.fileData(:,1)==subjects(i),2)];
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
                obj.fileData = D.(sprintf('sub%02d_sess%02d', obj.subjectNum, obj.sessionNum)).values;
                obj.epochTime = size(obj.fileData, 1);
                obj.epochTime = obj.epochTime / obj.dataRate;
            else
                obj.fileData = getSubject(obj, 1:obj.numChannels);
            end
            
            obj.dataSize = size(obj.fileData);
            
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
            obj.selectedData = obj.fileData;
            obj.selectedEpochs = ones(1, obj.dataSize(3)) == 1;
        end
    end
    methods (Access = public)
        function plotData(obj)
            obj.abscissa = obj.interval(1) + 1/obj.dataRate:1/obj.dataRate:obj.interval(2);
            dataSst = obj.getSstData;
            plotData@sstData(dataSst);
        end
        
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
            
            allEPochNums = 1:size(obj.fileData, 3);
            if(obj.exEpochsOnOff)
                obj.epochNums = allEPochNums(obj.extrials & obj.selectedEpochs);
            else
                obj.epochNums = allEPochNums(obj.selectedEpochs);
            end
            obj.selectedData = obj.fileData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
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
                obj.selectedData = obj.fileData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
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
                obj.selectedData = obj.fileData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
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
                obj.selectedData = obj.fileData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_INTERVAL_CHANGED));
            else
                ME = MException('eegData:load:noSuchInterval', 'Invalid interval selected.');
                throw(ME)
            end
        end
        function excludeEpochs(obj, onOff)
            if(onOff ~= obj.exEpochsOnOff)
                allEPochNums = 1:size(obj.fileData, 3);
                if(onOff)
                    obj.exEpochsOnOff = onOff;
                    obj.epochNums = allEPochNums(obj.extrials & obj.selectedEpochs);
                    
                else
                    obj.epochNums = allEPochNums(obj.selectedEpochs);
                    obj.exEpochsOnOff = onOff;
                end
                obj.selectedData = obj.fileData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                obj.currentEpochNum = 1;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_EPOCHS_CHANGED));
            end
        end
        
        function selectEpochs(obj, relativeEpochNums)
            allEPochNums = 1:size(obj.fileData, 3);
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
                obj.selectedData = obj.fileData(obj.getSelectedIndices,obj.channelNums,obj.epochNums);
                obj.dataSize = size(obj.selectedData);
                obj.currentEpochNum = 1;
                notify(obj,'dataSelectionChanged',eegDataEvent(eegData.EVENT_NAME_EPOCHS_CHANGED));
            else
                ME = MException('eegData:load:noSuchEpochs', 'Invalid epochs selected.');
                throw(ME)
            end
        end
    end
end

