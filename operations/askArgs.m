function [returnArgs] = askArgs(operationName, opData)
%askArgs
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.

OPERATIONS = {'Detrend', 'Normalize', 'Abs', 'Remove Common Mode', 'Resample',...
    'Filter', 'FFT', 'Spatial Filter',...
    'Select Channels', 'Create Epochs', 'Exclude Epochs',...
    'Channel Mean', 'Epoch Mean',...
    'Band Power', 'EEG Bands', 'BP Feat.'};

switch operationName
    
    case OPERATIONS{1} % Detrend
        % args{1} should be 'linear' or 'constant'.
        options = {'constant', 'linear'};
        [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','single',...
            'ListString', options, 'ListSize', [160 75]);
        returnArgs = options(s);
        
    case OPERATIONS{2} % Normalize
        % No argument required.
        returnArgs = {'N.R.'};
        
    case OPERATIONS{3} % Abs
        % No argument required.
        returnArgs = {'N.R.'};
        
    case OPERATIONS{4} % Remove Common Mode
        % No argument required.
        returnArgs = {'N.R.'};
        
    case OPERATIONS{5} % Resample
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
        
    case OPERATIONS{6} % Filter
        % args{1} should be isBandStop and args{2} should be frequencyBand
        prompt = {'isBandStop [0/1]:', 'Frequency band [fHigh fLow]:'};
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
        
    case OPERATIONS{7} % FFT
        % No argument required.
        returnArgs = {'N.R.'};
        
        
    case OPERATIONS{8} % Spatial Filter
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
        
    case OPERATIONS{9} % Select Channels
        % args{1} should be a vector with channel indices
        if(isempty(opData.channelNames))
            options = cellstr(num2str((1:opData.numChannels)'));
        else
            options = opData.channelNames;
        end
        [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','multiple',...
            'ListString', options, 'ListSize', [160 150]);
        if(isempty(s))
            returnArgs = {};
            return;
        end
        if(~isempty(opData.channelNames))
            returnArgs = {strcmpIND(opData.channelNames, options(s))};
        else
            returnArgs = {cellfun(@str2double, options(s))};
        end
        
    case OPERATIONS{10} % Create Epochs
        % args{1} should be [timeBefore timeAfter]
        if(opData.numEpochs > 1)
            returnArgs = {};
        else
            prompt = {'Epoch window [timeBefore timeAfter]:'};
            dlg_title = 'Epochs';
            num_lines = 1;
            defaultans = {'[3 3]'};
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
            if(isempty(answer))
                returnArgs = {};
                return;
            end
            wn = str2num(answer{1});
            if(isempty(wn))
                returnArgs = {};
            else
                if(length(wn) ~= 2)
                    returnArgs = {};
                    return;
                end
                returnArgs = {wn};
            end
        end
        
    case OPERATIONS{11} % Exclude Epochs
        % No argument required.
        returnArgs = {'N.R.'};
        
    case OPERATIONS{12} % Channel Mean
        % No argument required.
        returnArgs = {'N.R.'};
        
    case OPERATIONS{13} % Epoch Mean
        % No argument required.
        returnArgs = {'N.R.'};
        
    case OPERATIONS{14} % Band Power
        % args{1} should be frequencyBand
        prompt = {'Frequency band [fHigh fLow]:'};
        dlg_title = 'Band Power';
        num_lines = 1;
        defaultans = {'[0.05 5]'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        frequencyBand = str2num(answer{1});
        if(isempty(frequencyBand))
            returnArgs = {};
        else
            if(isnan(frequencyBand(1)) || isnan(frequencyBand(2))...
                    || frequencyBand(2) <= frequencyBand(1))
                returnArgs = {};
            else
                returnArgs = {frequencyBand};
            end
        end
    case OPERATIONS{15} % EEG Bands
        % No argument required.
        returnArgs = {'N.R.'};
        
    case OPERATIONS{16} % BP Feat.
        % No argument required.
        returnArgs = {'N.R.'};
        
    otherwise
        returnArgs = {};
end
end