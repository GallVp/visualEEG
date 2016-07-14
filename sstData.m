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
        numExcludedEpochs   % Number of excluded epochs
        staticCues
        warpedEpochs        % 1 if number of epochs has been changed due to any process
    end
    properties (Constant)
        DATA_TYPE_TIME_SERIES = 'TIME_SERIES';
        DATA_TYPE_FREQUENCY_SERIES = 'FREQUENCY_SERIES';
        DATA_TYPE_TIME_EVENT = 'TIME_EVENT';
        DATA_TYPE_PREDICTION = 'PREDICTION';
        
        PLOT_TYPE_PLOT = 'PLOT';
        PLOT_TYPE_STEM = 'STEM';
    end
    
    methods (Access = public)
        function setData(obj, selectedData, subjectNum, sessionNum, dataRate, channelNums, channelNames, interval, epochNums,...
                currentEpochNum, abscissa, dataType, numExcludedEpochs, staticCues, warpedEpochs)
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
            obj.numExcludedEpochs = numExcludedEpochs;
            obj.staticCues = staticCues;
            obj.warpedEpochs = warpedEpochs;
            
            obj.dataSize = [size(selectedData,1) size(selectedData,2) size(selectedData,3)];
        end
        function setChannelData(obj, selectedData, channelNums, channelNames)
            obj.selectedData = selectedData;
            obj.channelNums = channelNums;
            obj.channelNames = channelNames;
            
            obj.dataSize = [size(selectedData,1) size(selectedData,2) size(selectedData,3)];
        end
        
        function setResampledData(obj, selectedData, dataRate)
            obj.selectedData = selectedData;
            obj.dataRate = dataRate;
            obj.abscissa = obj.interval(1) + 1/obj.dataRate:1/obj.dataRate:obj.interval(2);
            obj.dataSize = [size(selectedData,1) size(selectedData,2) size(selectedData,3)];
            
        end
        
        function setFrequencyData(obj, selectedData, f)
            
            obj.selectedData = selectedData;
            obj.abscissa = f;
            obj.dataType = sstData.DATA_TYPE_FREQUENCY_SERIES;
            
            obj.dataSize = [size(selectedData,1) size(selectedData,2) size(selectedData,3)];
        end
        
        function setPredictionData(obj, y, pred)
            obj.warpedEpochs = 1;
            obj.selectedData = [y  pred];
            obj.dataSize = [size(obj.selectedData,1) size(obj.selectedData,2) size(obj.selectedData,3)];
            obj.channelNums = [1 2];
            obj.channelNames = {'Ground Truth','Prediction'};
            obj.abscissa = 1 : obj.dataSize(1);
            obj.dataType = sstData.DATA_TYPE_PREDICTION;
        end
        function setGrandData(obj, selectedData)
            
            obj.selectedData = selectedData;
            obj.epochNums = 1;
            obj.currentEpochNum = 1;
            obj.warpedEpochs = 1;
            
            obj.dataSize = [size(selectedData,1) size(selectedData,2) size(selectedData,3)];
            obj.channelNames = strcat('Grand\b', obj.channelNames);
            obj.channelNames = strrep(obj.channelNames, '\b', ' ');
        end
        function setSelectedData(obj, selectedData)
            obj.selectedData = selectedData;
            obj.dataSize = [size(selectedData,1) size(selectedData,2) size(selectedData,3)];
        end
        
        function setTimeEventData(obj, selectedData)
            obj.selectedData = selectedData;
            obj.dataSize = [size(selectedData,1) size(selectedData,2) size(selectedData,3)];
            
            obj.dataType = sstData.DATA_TYPE_TIME_EVENT;
        end
    end
    methods (Access = public)
        function plotData(obj)
            sstData.plotSstData(obj);
        end
        function plotCurrentEpoch(obj, showCue, showLegend, verbose)
            if nargin < 2
                showCue = 0;
                showLegend = 0;
                verbose = 1;
            end
            dispEpoch = obj.getEpoch;
            if(isempty(dispEpoch))
                axis([0 1 0 1]);
                text(0.38,0.5, 'No epochs available.');
            else
                if(strcmp(obj.dataType, sstData.DATA_TYPE_TIME_SERIES))
                    plot(obj.abscissa, dispEpoch)
                    if(verbose)
                        xlabel('Time (s)')
                        ylabel('Amplitude')
                    end
                elseif(strcmp(obj.dataType, sstData.DATA_TYPE_PREDICTION))
                    plot(obj.abscissa, dispEpoch(:,1,:), 'o', 'color', 'red')
                    hold on
                    plot(obj.abscissa, dispEpoch(:,2,:), '*', 'color', 'blue')
                    hold off
                    if(verbose)
                        xlabel('Sample Number')
                        ylabel('Label')
                    end
                else
                    stem(obj.abscissa, dispEpoch)
                    if(verbose)
                        xlabel('Frequency (Hz)')
                        ylabel('Amplitude')
                    end
                end
            end
            
            % Show Static Cue
            if(showCue)
                hold on
                a = axis;
                cuedata = obj.getCueTime;
                for i=1:length(cuedata)
                    line([cuedata(i) cuedata(i)], [a(3) a(4)], 'LineStyle','--', 'Color', 'red', 'LineWidth', 1);
                end
                axis(a);
                hold off
            end
            % if(handles.dynamicCue)
            %     hold on
            %     a = axis;
            %     ext = cell2mat(handles.cues(cell2mat(handles.cues(:,1))==handles.subjectNum & cell2mat(handles.cues(:,2))==handles.sessionNum,3));
            %     try
            %         cueTime = ext(handles.epochNum);
            %         line([cueTime+handles.dynamicCueOffset cueTime+handles.dynamicCueOffset], [a(3) a(4)],...
            % 'LineStyle','--', 'Color', 'blue', 'LineWidth', 1);
            %     catch ME
            %         disp(ME)
            %         disp('Probable cause: Dynamic cues not available for selected subject/session.')
            %     end
            %     axis(a);
            %     hold off
            % end
            
            
            %Update Legend
            if(showLegend)
                legend(obj.channelNames);
            else
                legend off
            end
            if(verbose)
                set(gca,'FontName','Helvetica');
                set(gca,'FontSize',12);
                set(gca,'LineWidth',2);
                set(gcf,'Color',[1 1 1]);
            end
        end
        function [indices] = getSelectedIndices(obj)
            indices = round((obj.interval(1) + 1/obj.dataRate : 1/obj.dataRate : obj.interval(2)) .* obj.dataRate);
        end
        function [epoch] = getEpoch(obj)
            try
                epoch = obj.selectedData(:,:,obj.currentEpochNum);
            catch ME
                disp(ME);
                epoch = [];
                
                obj.currentEpochNum = 0;
            end
        end
        function selectEpochGroup(obj, numGroups, groupNum)
            if(numGroups <= 0 || groupNum > numGroups || groupNum <=0)
                ME = MException('sstData:select:invalidGrouping', 'Invalid grouping.');
                throw(ME)
            else
                allEPochNums = 1:obj.dataSize(3);
                numEpochPerGroup = round(obj.dataSize(3) / numGroups);
                eNs = numEpochPerGroup * (groupNum - 1) + 1 : numEpochPerGroup * groupNum;
                eNs = eNs(eNs <= obj.dataSize(3));
                obj.epochNums = allEPochNums(eNs);
                obj.selectedData = obj.selectedData(:,:,eNs);
                obj.staticCues = obj.staticCues(:, eNs);
                obj.dataSize = size(obj.selectedData);
                obj.currentEpochNum = 1;
            end
        end
        function shiftCues(obj, delayVect)
            if(length(delayVect) <= size(obj.staticCues,1))
                for i=1:length(delayVect)
                    obj.staticCues(i,:) = obj.staticCues(i,:) + delayVect(i);
                end
            else
                obj.staticCues = [obj.staticCues; zeros(length(delayVect) - 1, size(obj.staticCues,2))];
                for i=1:length(delayVect)
                    obj.staticCues(i,:) = obj.staticCues(i,:) + delayVect(i);
                end
            end
        end
        function [answer] = isempty(obj)
            answer = isempty(obj.selectedData);
        end
        function [answer] = isEpochPresent(obj, absoluteEpochNum)
            answer = sum(ismember(obj.epochNums, absoluteEpochNum));
        end
        function [answer] = isLastEpoch(obj)
            answer = obj.currentEpochNum == obj.dataSize(3);
        end
        function [answer] = isFirstEpoch(obj)
            answer = obj.currentEpochNum == 1 || obj.currentEpochNum == 0;
        end
        function [epochNum] = getAbsoluteEpochNum(obj, relativeEpochNum)
            if nargin < 2
                relativeEpochNum = obj.currentEpochNum;
            end
            try
                epochNum = obj.epochNums(relativeEpochNum);
            catch ME
                disp(ME);
                disp('Invalid epochs selected.');
                epochNum = 0;
            end
        end
        function [cueTime] = getCueTime(obj)
            cueTime = obj.staticCues(:,obj.currentEpochNum);
        end
        function [obj] = nextEpoch(obj)
            if(obj.isLastEpoch)
                ME = MException('eegData:select:lastEpoch', 'Current epoch is the last epoch.');
                throw(ME)
            else
                obj.currentEpochNum = obj.currentEpochNum + 1;
            end
        end
        function [obj] = previousEpoch(obj)
            if(obj.isFirstEpoch)
                ME = MException('eegData:select:firstEpoch', 'Current epoch is the first epoch.');
                throw(ME)
            else
                obj.currentEpochNum = obj.currentEpochNum - 1;
            end
        end
    end
    methods (Access = public, Static)
        function [ X, y] = splitData(dataSst, segAInterval, segBInterval, dataRate, permu)
            
            
            %loading data
            indicesa = round([segAInterval(1)+1/dataRate segAInterval(2)] .* dataRate);
            indicesb = round([segBInterval(1)+1/dataRate segBInterval(2)] .* dataRate);
            segment1 = dataSst(indicesa(1):indicesa(2),:,:);
            segment2 = dataSst(indicesb(1):indicesb(2),:,:);
            
            
            segmentedData = cat(3,segment1,segment2);
            
            
            [m, n, o] = size(segmentedData);
            
            %Dimension Description
            %m=samples
            %n=channels
            %o=trials
            
            
            X = zeros(o,m*n);
            for k=1:o
                temp = segmentedData(:,:,k);
                X(k,:) = temp(:);
            end
            
            total_examples = o;
            y = [zeros(total_examples/2,1); ones(total_examples/2,1)];
            
            switch permu
                case 0
                    P = randperm(total_examples);
                    X_y = [X y];
                    X_y = X_y(P,:);
                    X = X_y(:,1:end-1);
                    y = X_y(:,end);
                case 1
                    P = ones(1,total_examples) == 1;
                    X_y = [X y];
                    X_y = X_y(P,:);
                    X = X_y(:,1:end-1);
                    y = X_y(:,end);
                case 2
                    P = [1:total_examples/2; total_examples/2+1:total_examples];
                    P = P(:);
                    X_y = [X y];
                    X_y = X_y(P,:);
                    X = X_y(:,1:end-1);
                    y = X_y(:,end);
            end
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
        
        function [xSst, y] = splitIntoSegments(dataSst, indicesA, indicesB)
            xSst1 = dataSst(indicesA(1):indicesA(2),:,:);
            Sst2 = dataSst(indicesB(1):indicesB(2),:,:);
            xSst = cat(3,xSst1,XSst2);
            
            totalEpochs = size(xSst, 3); % Total epochs are always even
            y = [ones(totalEpochs/2,1); ones(totalEpochs/2,1).*2]; % Label the epochs
        end
        
        function [shuffledXSst, shuffledY] = shuffleEpochs(xSst, y, permu)
            
            totalEpochs = size(xSst, 3); % Total epochs are always even
            
            switch permu
                case 0 % Random
                    p = randperm(totalEpochs);
                    shuffledXSst = xSst(:,:,p);
                    shuffledY = y(p);
                case 1 % Sequential
                    p = ones(1,totalEpochs) == 1;
                    shuffledXSst = xSst(:,:,p);
                    shuffledY = y(p);
                case 2 % Alternative
                    p = [1:totalEpochs/2; totalEpochs/2+1:totalEpochs];
                    p = p(:);
                    shuffledXSst = xSst(:,:,p);
                    shuffledY = y(p);
                otherwise
                    ME = MException('sstData:noSuchPermutation', 'Permutation option not available');
                    throw(ME);
            end
        end
        
        
        function exportNeuCubeData(folderName, subjectNum, sessionNum, rawData, intvla,...
                intvlb, datarate, testpc)
            
            
            %loading data
            indicesA = [intvla(1)+1/datarate intvla(2)] .* datarate;
            indicesB = [intvlb(1)+1/datarate intvlb(2)] .* datarate;
            
            [m, n, o, p] = size(subjectData);
            
            %Dimension Description
            %m=samples
            %n=channels
            %o=trials
            %p=sessions
            
            %Features
            % Raw data is taken as features
            % X is two dimensional. Datasamples are along rows and features are along
            % columns.
            
            X = zeros(o*p,m*n);
            for j=1:p
                for k=1:o
                    temp = subjectData(:,:,k,j);
                    X(j*k,:) = temp(:);
                end
            end
            
            total_examples = o*p;       %Total examples are always even
            y = [ones(total_examples/2,1); ones(total_examples/2,1).*2];
            
            %Copy data from end of X and y to create Xtest and ytest
            test_examples = floor(testpc / 100 * (total_examples/2));
            nt_examples = total_examples/2 - test_examples;
            
            ytest = [y(nt_examples+1:total_examples/2);y(total_examples/2+nt_examples+1:end)];
            Xtest = [X(nt_examples+1:total_examples/2,:); X(total_examples/2+nt_examples+1:end,:)];
            
            [~,~,~] = mkdir(folderName, 'NeuCube Data');
            [~,~,~] = rmdir(strcat(folderName, '/NeuCube Data/', sprintf('sub%02d_sess%02d',...
                subjectNum, sessionNum)), 's');
            [~,~,~] = mkdir(strcat(folderName, '/NeuCube Data'), sprintf('sub%02d_sess%02d',...
                subjectNum, sessionNum));
            [~,~,~] = mkdir(strcat(folderName, '/NeuCube Data/', sprintf('sub%02d_sess%02d',...
                subjectNum, sessionNum)), 'TestData');
            
            for i=1:total_examples
                A = reshape(X(i,:),[m n]);
                csvwrite(fullfile(strcat(folderName, sprintf('/NeuCube Data/sub%02d_sess%02d',...
                    subjectNum, sessionNum)), sprintf('sam%d.csv',i)),A);
            end
            
            csvwrite(fullfile(strcat(folderName, sprintf('/NeuCube Data/sub%02d_sess%02d',...
                subjectNum, sessionNum)), 'tar_class_labels.csv'), y);
            
            %Saving Test Data
            for i=1:test_examples*2
                A = reshape(Xtest(i,:),[m n]);
                csvwrite(fullfile(strcat(folderName, sprintf('/NeuCube Data/sub%02d_sess%02d',...
                    subjectNum, sessionNum),'/TestData'), sprintf('sam%d.csv',i)),A);
            end
            
            csvwrite(fullfile(strcat(folderName, sprintf('/NeuCube Data/sub%02d_sess%02d',...
                subjectNum, sessionNum),'/TestData'), 'tar_class_labels.csv'), ytest);
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
            
            
            H = figure('Visible','off', 'Units', 'pixels','ResizeFcn',@handleResize);
            persistant.enlargeFactor = 50;
            hPos = get(H, 'Position');
            hPos(4) = hPos(4) + persistant.enlargeFactor;
            set(H, 'Position', hPos);
            
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
            set(H, 'Visible','on');
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

