function [ dataOut, timeVect ] = matchedFilterSstData( template, sstData, step, dataRate, verbose, roiTime )

% Copyright (c) <2016> <Usman Rashid>
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% LICENSE included with this distribution for more information.
    
    testForSize = matchedFilter(template, sstData(:,:, 1), step, dataRate);
    [~, n, o] = size(sstData);
    dataOut = zeros(length(testForSize), n, o);
    for k=1:size(sstData, 3)
        dataOut(:,:,k) = matchedFilter(template, sstData(:,:, k), step, dataRate);
    end
    
    lenTemplate = length(template);
    timeVect = [lenTemplate / dataRate...
    lenTemplate / dataRate + step/1000 : step/1000 :...
    lenTemplate / dataRate + (size(dataOut, 1) - 1) * step/1000];

    if(verbose)
        abscissa = roiTime(1) + timeVect;
        abscissa2 = roiTime(1) + 1 / dataRate: 1 / dataRate : roiTime(2);
        
        plotMatchedData({abscissa; abscissa2}, {dataOut; sstData},{'Similarity Index';'Actual Data'}...
            , {eegData.PLOT_TYPE_STEM;eegData.PLOT_TYPE_PLOT}, roiTime, template);
    end


    function [ reelOut ] = matchedFilter( template, reelIn, step, dataRate )
        
        % Both template and reelIn should be column vectors.
        % Step should be in miliseconds.
        
        numStepSamples = floor(step / 1000 * dataRate);
        numSteps = floor(size(reelIn, 1) / numStepSamples); % This is an exagerated estimate
        numTemplateSamples = length(template);
        reelOut = zeros(numSteps, 1);
        
        stepNum = 0;
        
        while (1)
            reelSampleNum = 1 + stepNum * numStepSamples : numTemplateSamples + stepNum * numStepSamples;
            if(max(reelSampleNum) > length(reelIn))
                break;
            else
                stepNum = stepNum + 1;
                reelOut(stepNum) = corr(template, reelIn(reelSampleNum));
            end
        end
        reelOut = reelOut(1:stepNum);
        reelOut = (reelOut + 1) ./ 2;
    end

    function H = plotMatchedData(abscissa, sstData, titleText, plotType, xAxisLimits, movingData)
        % Create a figure and axes
        % xAxisLimits = -1 means that this argument is not used
        % sstData, abscicca, titleText and plotType should be m * 1 cell arrays.
        % In this case the matchedData should be in the first row of the
        % cells and the actual data should be in the second row.
        
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
            ax = cell(persistant.numDats, 1);
            ax{1} = subplot(persistant.numDats, 1, 1, 'Units', 'pixels');
            ax{2} = subplot(persistant.numDats, 1, 2, 'Units', 'pixels');
            pos = get(ax{1}, 'Position');
            pos(2) = pos(2) + enlargeFactor / 2;
            pos(4) = pos(4) - enlargeFactor / 3;
            set(ax{1}, 'Position', pos);
            pos = get(ax{2}, 'Position');
            pos(2) = pos(2) + enlargeFactor / 2;
            pos(4) = pos(4) - enlargeFactor / 3;
            set(ax{2}, 'Position', pos);
            
            yDat = sstData{2};
            xDat = 1/dataRate:1/dataRate:length(movingData)/dataRate;
            xDat = xDat + abscissa{1}(1) - length(movingData) / dataRate;
            plot(ax{2}, abscissa{2}, yDat(:,:,persistant.trialNum), xDat, movingData, 'LineWidth', 2);
            stem(ax{1}, abscissa{1}, [sstData{1}(:,:,persistant.trialNum)...
                (abs(abscissa{1} - abscissa{1}(1)) < step/2000)' .*...
                sstData{1}(abs(abscissa{1} - abscissa{1}(1))< step/2000,:,persistant.trialNum)],...
                'LineWidth', 2, 'LineStyle', '--', 'Marker', 'square', 'MarkerSize', 8, 'buttonDownfcn', @plotMovingData);
            if(xAxisLimits ~= -1)
                axL = axis(ax{1});
                axL = [xAxisLimits(1) xAxisLimits(2) axL(3) axL(4)];
                axis(ax{1},axL);
            end
            xlabel(ax{2}, 'Time (s)')
            ylabel(ax{2}, 'Amplitude')
            title(ax{2}, titleText{2})
            xlabel(ax{1}, 'Time (s)')
            ylabel(ax{1}, 'Amplitude')
            title(ax{1}, titleText{1})
            legend(ax{2}, 'Actual Data', 'Template')
            
            
            
            function plotMovingData(source,callbackdata)
                yDat = sstData{2};
                xDat = 1/dataRate:1/dataRate:length(movingData)/dataRate;
                xDat = xDat + callbackdata.IntersectionPoint(1) - length(movingData) / dataRate;
                plot(ax{2}, abscissa{2}, yDat(:,:,persistant.trialNum), xDat, movingData, 'LineWidth', 2);
                stem(ax{1}, abscissa{1}, [sstData{1}(:,:,persistant.trialNum)...
                    (abs(abscissa{1} - callbackdata.IntersectionPoint(1))...
                    < step/2000)' .* sstData{1}(abs(abscissa{1} - callbackdata.IntersectionPoint(1))< step/2000, :, persistant.trialNum)],...
                    'LineWidth', 2, 'LineStyle', '--', 'Marker', 'square', 'MarkerSize', 8, 'buttonDownfcn', @plotMovingData);
                if(xAxisLimits ~= -1)
                    axL = axis(ax{1});
                    axL = [xAxisLimits(1) xAxisLimits(2) axL(3) axL(4)];
                    axis(ax{1},axL);
                end
                xlabel(ax{2}, 'Time (s)')
                ylabel(ax{2}, 'Amplitude')
                title(ax{2}, titleText{2})
                xlabel(ax{1}, 'Time (s)')
                ylabel(ax{1}, 'Amplitude')
                title(ax{1}, titleText{1})
                legend(ax{2}, 'Actual Data', 'Template')
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