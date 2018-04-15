function [argFunc, opFunc] = moveMean
%moveMean Applies moving average.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be K, the number of samples.
        prompt = {sprintf('Enter number of samples (fs = %d)', opData.fs)};
        dlg_title = 'Moving Mean';
        num_lines = 1;
        defaultans = {num2str(opData.fs)};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        K = str2double(answer{1});
        if(isempty(K))
            returnArgs = {};
        else
            if(K <= 0 || isnan(K))
                returnArgs = {};
            else
                returnArgs = {K};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be K, the number of samples.
        K = args{1};
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(sz(1), sz(2), sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = movmean(opData.channelStream(:, :, i), K);
            end
        else
            processedData   = movmean(opData.channelStream, K);
        end
        opDataOut.channelStream = processedData;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function updateView(axH, opData)
    end
end