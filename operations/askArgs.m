function [returnArgs] = askArgs(operationName, opData)

ALL_OPERATIONS = {'Detrend', 'Normalize', 'Abs', 'Remove Common Mode', 'Resample',...
    'Filter', 'FFT', 'Spatial Filter',...
    'Select Channels', 'Create Epochs',...
    'Channel Mean', 'Epoch Mean'};

switch operationName
    
    case ALL_OPERATIONS{1} % Detrend
        % args{1} should be 'linear' or 'constant'.
        options = {'constant', 'linear'};
        [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','single',...
            'ListString', options, 'ListSize', [160 75]);
        returnArgs = options(s);
        
    case ALL_OPERATIONS{2} % Normalize
        % No argument required.
        returnArgs = {'N.R.'};
        
    case ALL_OPERATIONS{3} % Abs
        % No argument required.
        returnArgs = {'N.R.'};
        
    case ALL_OPERATIONS{4} % Remove Common Mode
        % No argument required.
        returnArgs = {'N.R.'};
        
    case ALL_OPERATIONS{5} % Resample
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
        
    case ALL_OPERATIONS{6} % Filter
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
        
    case ALL_OPERATIONS{7} % FFT
        % No argument required.
        returnArgs = {'N.R.'};
        
        
    case ALL_OPERATIONS{8} % Spatial Filter
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
        
    case ALL_OPERATIONS{9} % Select Channels
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
        
    case ALL_OPERATIONS{10} % Create Epochs
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
        
    case ALL_OPERATIONS{11} % Channel Mean
        % No argument required.
        returnArgs = {'N.R.'};
        
    case ALL_OPERATIONS{12} % Epoch Mean
        % No argument required.
        returnArgs = {'N.R.'};
        
        %
        %     case eegOperations.ALL_OPERATIONS{8} % PCA
        %         returnArgs = {'N.R.'};
        %         obj.storedArgs.('eignVect') = [];
        %         % storedArgs is cleared here to ensure that when
        %         % this operation is added after removal, it asks for
        %         % argument during operation execution.
        %         % No argument required. Which in fact is delayed to
        %         % applyOpertion.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{9} % FAST ICA
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        
        
    otherwise
        returnArgs = {};
end
end