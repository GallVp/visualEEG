classdef sstData < matlab.mixin.Copyable
    %SSTDATA A class representing sstData
    % The properties represent information relative to actual data.
    
    % Copyright (c) <2016> <Usman Rashid>
    %
    % This program is free software; you can redistribute it and/or
    % modify it under the terms of the GNU General Public License as
    % published by the Free Software Foundation; either version 2 of the
    % License, or (at your option) any later version.  See the file
    % LICENSE included with this distribution for more information.
    
    properties (SetAccess = protected)
        selectedData        % Current selection of data
        dataSize            % Size of sstData
        subjectNum          % Current selected subject
        sessionNum          % Current selected session
        dataRate            % Data sample rate
        channelNums         % Nums of currently selected channels
        channelNames        % Names of currently selected channels
        interval            % Interval of selected data
        epochNums           % Sr. Nos of epochs
        currentEpochNum     % Currently selected epoch
        abscissa            % x-axis data
        dataType            % Type of data contained in selected Data
    end
    properties (Constant)
        DATA_TYPE_TIME_SERIES = 'TIME_SERIES';
                
        PLOT_TYPE_PLOT = 'PLOT';
        PLOT_TYPE_STEM = 'STEM';
    end
    
    methods (Access = public)
        function setData(obj, selectedData, subjectNum, sessionNum, dataRate, channelNums, channelNames, interval, epochNums,...
                currentEpochNum, abscissa, dataType)
            obj.selectedData = selectedData;
            obj.subjectNum = subjectNum;
            obj.sessionNum = sessionNum;
            obj.dataRate = dataRate;
            obj.channelNums = channelNums;
            obj.channelNames = channelNames;
            obj.interval = interval;
            obj.epochNums = epochNums;
            obj.currentEpochNum = currentEpochNum;
            obj.abscissa = abscissa;
            obj.dataType = dataType;
            
            obj.dataSize = size(selectedData);
        end
        function setChannelData(obj, selectedData, channelNums, channelNames)
            obj.selectedData = selectedData;
            obj.channelNums = channelNums;
            obj.channelNames = channelNames;
            
            obj.dataSize = size(selectedData);
        end
        function setEpochData(obj, selectedData, epochNums)
            obj.selectedData = selectedData;
            obj.epochNums = epochNums;
            obj.currentEpochNum = epochNums(1);
            
            obj.dataSize = size(selectedData);
        end
        function setSelectedData(obj, selectedData)
            obj.selectedData = selectedData;
            obj.dataSize = size(selectedData);
        end
    end
    methods (Access = public)
        function plotData(obj)
            sstData.plotSstData(obj);
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
        function [ X, Xcv, Xtest, y, ycv, ytest] = splitData(fileData, intvla, intvlb, dataRate,  trainPer, cvPer, testPer)
            
            
            %loading data
            indicesa = round([intvla(1)+1/dataRate intvla(2)] .* dataRate);
            indicesb = round([intvlb(1)+1/dataRate intvlb(2)] .* dataRate);
            subjectData1 = fileData(indicesa(1):indicesa(2),:,:,:);
            subjectData2 = fileData(indicesb(1):indicesb(2),:,:,:);
            
            
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
        function [ X, Xcv, Xtest] = splitDataMF(fileData, tIntvl, roiIntvl, dataRate,  trainPer, cvPer, testPer)
            
            % queueTime = -1 means that the movement is unqueued.
            
            %loading data
            indicesT = round([tIntvl(1)+1/dataRate tIntvl(2)] .* dataRate);
            indicesR = round([roiIntvl(1)+1/dataRate roiIntvl(2)] .* dataRate);
            
            total_trials = size(fileData, 3);
            
            train_trials = floor(total_trials * trainPer / 100);
            cv_trials = floor(total_trials * cvPer / 100);
            test_samples = floor(total_trials * testPer / 100);
            
            X = fileData(indicesT(1):indicesT(2),:,1:train_trials);
            Xcv = fileData(indicesR(1):indicesR(2),:,train_trials+1:train_trials+cv_trials);
            Xtest = fileData(indicesR(1):indicesR(2),:, train_trials+cv_trials + 1:end);
        end
        function H = plotSstData(dataSst, titleText, plotType, xAxisLimits)
            % Create a figure and axes
            % xAxisLimits = -1 means that this argument is not used
            % dataSst should be an object of class sstData
            persistant.abscissa = dataSst.abscissa;
            persistant.ordinate = dataSst.selectedData;
            persistant.trialNum = dataSst.currentEpochNum;
            persistant.legendInfo = dataSst.channelNames;
            switch(nargin)
                case 1
                    persistant.titleText = sprintf('Sub:%02d Sess:%02d', dataSst.subjectNum, dataSst.sessionNum);
                    persistant.plotType = sstData.PLOT_TYPE_PLOT;
                    persistant.xAxisLimits = -1;
                case 2
                    persistant.titleText = titleText;
                    persistant.plotType = sstData.PLOT_TYPE_PLOT;
                    persistant.xAxisLimits = -1;
                case 3
                    persistant.titleText = titleText;
                    persistant.plotType = plotType;
                    persistant.xAxisLimits = -1;
                case 4
                    persistant.titleText = titleText;
                    persistant.plotType = plotType;
                    persistant.xAxisLimits = xAxisLimits;
            end
            
            persistant.totalEpochs = size(persistant.ordinate, 3);
            
            
            H = figure('Visible','off', 'Units', 'pixels','SizeChangedFcn',@handleResize);
            persistant.enlargeFactor = 50;
            H.Position(4) = H.Position(4) + persistant.enlargeFactor;
            
            % Create push button
            persistant.btnNext = uicontrol('Style', 'pushbutton', 'String', 'Next',...
                'Position', [300 20 75 20],...
                'Callback', @next);
            
            persistant.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
                'Position', [200 20 75 20],...
                'Callback', @previous);
            
            
            % Add a text uicontrol.
            persistant.txtEpochInfo = uicontrol('Style','text',...
                'Position',[75 17 120 20]);
            
            updateView
            
            % Make figure visble after adding all components
            H.Visible = 'on';
            % This code uses dot notation to set properties.
            % Dot notation runs in R2014b and later.
            % For R2014a and earlier: set(f,'Visible','on');
            
            function next(~,~)
                persistant.trialNum = persistant.trialNum + 1;
                updateView
            end
            
            function previous(~,~)
                persistant.trialNum = persistant.trialNum - 1;
                updateView
            end
            
            function handleResize(src,callbackdata)
                updateView
            end
            
            function updateView
                ax = subplot(1, 1, 1, 'Units', 'pixels');
                
                if(strcmp(persistant.plotType, eegData.PLOT_TYPE_PLOT))
                    dat = persistant.ordinate;
                    plot(persistant.abscissa, dat(:,:,persistant.trialNum), 'LineWidth', 2)
                else
                    dat = persistant.ordinate;
                    stem(persistant.abscissa, dat(:,:,persistant.trialNum), 'LineWidth', 2)
                end

                xlabel('Time (s)')
                ylabel('Amplitude')
                title(persistant.titleText)
                legend(persistant.legendInfo);
                
                if(persistant.xAxisLimits ~= -1)
                    axL = axis;
                    axL = [persistant.xAxisLimits(1) persistant.xAxisLimits(2) axL(3) axL(4)];
                    axis(axL);
                end
                pos = get(ax, 'Position');
                pos(2) = pos(2) + persistant.enlargeFactor / 2;
                pos(4) = pos(4) - persistant.enlargeFactor / 3;
                set(ax, 'Position', pos);
                
                if persistant.trialNum == persistant.totalEpochs
                    set(persistant.btnNext, 'Enable', 'Off');
                else
                    set(persistant.btnNext, 'Enable', 'On');
                end
                if persistant.trialNum == 1
                    set(persistant.btnPrevious, 'Enable', 'Off');
                else
                    set(persistant.btnPrevious, 'Enable', 'On');
                end
                set(persistant.txtEpochInfo, 'String', sprintf('Epoch : %d/%d', persistant.trialNum, persistant.totalEpochs))
            end
        end
    end
end

