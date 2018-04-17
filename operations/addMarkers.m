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
        prompt = {'Number of markers:', 'Names of markers [Optional](separated by comma):'};
        dlg_title = 'Add markers';
        num_lines = 1;
        defaultans = {'3', 'm1, m2, m3'};
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
        [x, y] = ginput(numMarkers);
        markerData(:,:, opData.epochNum) = cat(2, x, y);
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
        function defaultUpdateView(axH, opData)
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
        function oldAndNewUpdateView(axH, passedData)
            oldUpdateView(axH, passedData);
            updateView(axH, passedData);
        end
        opDataOut.updateView = @oldAndNewUpdateView;
        
        % Create a function which should be called on epoch switch
        function opDataOut = onEpochSwitch(opData)
            opDataOut = opData;
            if(~isnan(opData.markerData(1,1, opData.epochNum)))
                return;
            end
            numMarkersLocal = size(opData.markerData, 1);
            [xLocal, yLocal] = ginput(numMarkersLocal);
            opDataOut.markerData(:,:, opData.epochNum) = cat(2, xLocal, yLocal);
        end
        opDataOut.onEpochSwitch = @onEpochSwitch;
    end
%% Update the view
    function updateView(axH, opData)
        hold on;
        for i = 1:size(opData.markerData, 1)
            plot(axH, opData.markerData(i, 1, opData.epochNum), opData.markerData(i, 2, opData.epochNum),...
                'r.', 'LineWidth', 2, 'MarkerSize', 15);
            if(~isempty(opData.markerNames))
                markerNames = strsplit(opData.markerNames, ',');
                text(axH, opData.markerData(i, 1, opData.epochNum), opData.markerData(i, 2, opData.epochNum),...
                    sprintf(' --> %s', markerNames{i}), 'FontSize', 12);
            end
        end
        hold off;
    end
end