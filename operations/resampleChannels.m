function [argFunc, opFunc] = resampleChannels
%resampleChannels Resample the channels using MATLAB resample function.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be p and args{2} should be q. p/q is
        % the sampling ratio.
        prompt = {'p:', 'q:'};
        dlg_title = 'Ratio p/q';
        num_lines = 1;
        defaultans = {'1', '2'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        p = str2double(answer{1});
        q = str2double(answer{2});
        if(isempty(p) || isempty(q))
            returnArgs = {};
        else
            if(p <= 0 || q <=0 || isnan(p) || isnan(q))
                returnArgs = {};
            else
                returnArgs = {p, q};
            end
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be p and args{2} should be q. p/q is
        % the sampling ratio.
        p = args{1};
        q = args{2};
        if(opData.numEpochs > 1)
            sz = size(opData.channelStream);
            processedData = zeros(sz(1) * p / q, sz(2), sz(3));
            for i=1:opData.numEpochs
                processedData(:, :, i) = resample(opData.channelStream(:, :, i), p, q);
            end
        else
            processedData   = resample(opData.channelStream, p, q);
        end
        opDataOut.channelStream = processedData;
        if(~isempty(opData.events))
            opDataOut.events    = round(opData.events .* p / q);
        end
        opDataOut.fs            = opData.fs * p / q;
        opDataOut.abscissa      = 1:size(opDataOut.channelStream, 1);
        opDataOut.abscissa      = opDataOut.abscissa ./ opDataOut.fs;
        
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end