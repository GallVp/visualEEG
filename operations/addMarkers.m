function [argFunc, opFunc] = addMarkers
%addMarkers Adds markers to data using MATLAB ginput
%   function.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be numMarkers and args{2} should be markerNames.
        prompt = {'Number of markers:', 'Names of markers [Optional](separated by ;):'};
        dlg_title = 'Add markers';
        num_lines = 1;
        if(isfield(opData, 'markerNames'))
            defaultans = {num2str(size(strsplit(opData.markerNames), 2)), opData.markerNames};
        else
            defaultans = {'3', 'm1; m2; m3'};
        end
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        numMarkers = str2double(answer{1});
        markerNames = answer{2};
        if(isempty(numMarkers))
            returnArgs = {};
        else
            if(numMarkers <= 0 || isnan(numMarkers))
                returnArgs = {};
            else
                returnArgs = {numMarkers, markerNames};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be numMarkers and args{2} should be markerNames.
        numMarkers  = args{1};
        markerNames = args{2};
        markerData  = NaN .* ones(numMarkers, 2, opData.numEpochs); % 2 for x and y
        opDataOut.markerData    = markerData;
        opDataOut.markerNames   = markerNames;
        % Add custom updateView function along with the previous updateView
        % In case there was no previous updateView, use the default
        % updateView. This is a very powerful technique to chain updateView
        % functions.
        oldUpdateView = opData.updateView;
        if(isempty(oldUpdateView))
            oldUpdateView = @defaultUpdateView;
        end
        function opDataOut = defaultUpdateView(axH, opData)
            opDataOut = opData;
            % Code directly copied from updateView function in visualEEG.m
            % Plot data
            dat = opData.channelStream;
            
            if(size(dat, 2) > 128)
                disp('Warning: Only plotting first 128 channels');
                dat = dat(:, 1:128);
            end
            absc = opData.abscissa;
            
            plot(axH, absc, dat(:,:, opData.epochNum));
            % Set axis labels
            xlabel('Time (s)');
            ylabel('Amplitude');
        end
        function opDataOut = oldAndNewUpdateView(axH, passedData)
            opDataOut = oldUpdateView(axH, passedData);
            opDataOut = updateView(axH, opDataOut);
        end
        opDataOut.updateView = @oldAndNewUpdateView;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
        hold on;
        dataTest = opData.markerData(1, 1, opData.epochNum);
        if(isnan(dataTest))
            numMarkers = size(opData.markerData, 1);
            % Disable all buttons
            setPropertyOn(axH, 'pb[a-zA-Z]*', 'Enable', 'Off');
            [x, y] = ginputWithPlot(axH, numMarkers, opDataOut.markerNames);
            % Enable all buttons
            setPropertyOn(axH, 'pb[a-zA-Z]*', 'Enable', 'On');
            opDataOut.markerData(:,:, opData.epochNum) = cat(2, x, y);
        else
            for i = 1:size(opDataOut.markerData, 1)
                plot(axH, opDataOut.markerData(i, 1, opDataOut.epochNum), opDataOut.markerData(i, 2, opDataOut.epochNum),...
                    'r.', 'LineWidth', 2, 'MarkerSize', 15);
                if(~isempty(opDataOut.markerNames))
                    markerNames = strsplit(opDataOut.markerNames, ';');
                    text(axH, opDataOut.markerData(i, 1, opDataOut.epochNum), opDataOut.markerData(i, 2, opDataOut.epochNum),...
                        sprintf(' --> %s', markerNames{i}), 'FontSize', 12);
                end
            end
        end
        hold off;
    end
end