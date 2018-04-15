function [argFunc, opFunc] = filterChannels
%filterChannels Apply filter to each channel with the specified options
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be isBandStop and args{2} should be frequencyBand
        prompt = {'isBandStop [0/1]:', 'Frequency band [fLow fHigh]:'};
        dlg_title = 'Filter Options';
        num_lines = 1;
        defaultans = {'0', '[0.05 5]'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        isBandStop = str2double(answer{1});
        frequencyBand = str2num(answer{2});
        if(isempty(isBandStop) || isempty(frequencyBand))
            returnArgs = {};
        else
            if(isnan(isBandStop) || isnan(frequencyBand(1)) || isnan(frequencyBand(2)) ||...
                    ~ismember(isBandStop, [1 0]) || frequencyBand(2) <= frequencyBand(1))
                returnArgs = {};
            else
                returnArgs = {isBandStop, frequencyBand};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be isBandStop and args{2} should be frequencyBand
        FILTER_ORDER    = 2;
        ZERO_PHASE      = 1;
        isBandStop = args{1};
        frequencyBand = args{2};
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                if(isBandStop)
                    processedData(:, :, i) = notchStream(opData.channelStream(:, :, i), opData.fs, frequencyBand);
                else
                    processedData(:, :, i) = filterStream(opData.channelStream(:, :, i), opData.fs,...
                        FILTER_ORDER, frequencyBand(2), frequencyBand(1), ZERO_PHASE);
                end
            end
        else
            if(isBandStop)
                processedData = notchStream(opData.channelStream, opData.fs, frequencyBand);
            else
                processedData = filterStream(opData.channelStream, opData.fs,...
                    FILTER_ORDER, frequencyBand(2), frequencyBand(1), ZERO_PHASE);
            end
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function updateView(axH, opData)
    end
end