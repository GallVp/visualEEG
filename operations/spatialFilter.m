function [argFunc, opFunc] = spatialFilter
%spatialFilter Apply a spatial filter
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Create a function which takes opData and returns a cell array of args
%% required by this operation
% args{1} should be the exponent
    function returnArgs = askArgs(opData)
        % args{1} should be channel weights
        prompt = {'Channel weights (No. of weights should be equal to number of channels):'};
        dlg_title = 'Spatial filter';
        num_lines = 1;
        defaultans = {num2str(ones(1, opData.numChannels))};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        cWeights = str2num(answer{1});
        if(isempty(cWeights))
            returnArgs = {};
        else
            if(length(cWeights) ~= opData.numChannels)
                returnArgs = {};
            end
            returnArgs = {cWeights};
        end
    end
%% Create a function which takes opData, args and returns processedData
%% and a view update function.
% args{1} should be the exponent
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be channel weights
        M = args{1};
        M = M';
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(sz(1), 1, sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = opData.channelStream(:, :, i) * M;
            end
        else
            processedData = opData.channelStream * M;
        end
        opDataOut.channelStream = processedData;
        opDataOut.channelNames = {'SF Channel'};
        opDataOut.numChannels = size(opDataOut.channelStream, 2);
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end

%% Create a update view function which takes axis handle and opData.
    function updateView(axH, opData)
    end
end