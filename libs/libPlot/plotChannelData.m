function H = plotChannelData(channelStream, fs, options)
% PLOTCHANNELDATA Creates a figure and axes showing channelStream Data.
%   channelStream is a matrix in which 1st dimension is the time and
%   second dimension is the channels.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

% Available option constants
persistant.PLOT_TYPE_PLOT   = 'PLOT';
persistant.PLOT_TYPE_STEM   = 'STEM';
persistant.DOMAIN_TIME      = 'TIME';
persistant.DOMAIN_FREQUENCY = 'FREQUENCY';
persistant.eventNames = {'Cue', 'Detected onsets', 'Selected onsets'};

% Assign default options
persistant.options.plotType         = persistant.PLOT_TYPE_PLOT;
persistant.options.legendInfo       = [];
persistant.options.title            = 'Channel Data';
persistant.options.xLabel           = {'Sample Number'};
persistant.options.yLabel           = 'Amplitude';
persistant.options.lineWidth        = 1;
persistant.options.markerLineWidth  = 1;
persistant.options.domain           = persistant.DOMAIN_TIME;
persistant.options.eventVector      = [];
persistant.options.onsetsVector     = [];
persistant.options.onsetsVector2    = [];
persistant.options.applyDetrend     = 1;
persistant.options.xShift           = 0;

switch(nargin)
    case 1
        persistant.channelStream = channelStream;
        persistant.fs = [];
        
    case 2
        persistant.channelStream = channelStream;
        persistant.fs = fs;
        persistant.options.xLabel= {'Time (s)'};
    case 3
        persistant.channelStream = channelStream;
        persistant.fs = fs;
        persistant.options.xLabel= {'Time (s)'};
        persistant.options = assignOptions(options, persistant.options);
end

persistant.numChannels = size(persistant.channelStream, 2);
persistant.channelNum = 1;

% Calculate abscissa from fs
if(isempty(persistant.fs))
    persistant.abscissa = 1:size(persistant.channelStream, 1);
    persistant.abscissa = persistant.abscissa - persistant.options.xShift;
else
    persistant.abscissa = (1:size(persistant.channelStream, 1)) ./ fs;
    persistant.abscissa = persistant.abscissa - persistant.options.xShift;
end

H = figure('Visible', 'off',...
    'Units', 'pixels',...
    'ResizeFcn', @handleResize,...
    'Name', 'Plot Channels Tool',...
    'numbertitle','off');
persistant.enlargeFactor = 50;
hPos = get(H, 'Position');
hPos(4) = hPos(4) + persistant.enlargeFactor;
set(H, 'Position', hPos);

% Create push buttons
persistant.btnNext = uicontrol('Style', 'pushbutton', 'String', 'Next',...
    'Position', [300 20 75 20],...
    'Callback', @next);

persistant.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
    'Position', [200 20 75 20],...
    'Callback', @previous);
if(~isempty(persistant.fs))
    persistant.btnSpectrum = uicontrol('Style', 'pushbutton', 'String', 'Spectrum',...
        'Position', [400 20 75 20],...
        'Callback', @spectrum);
end


% Add a text uicontrol.
persistant.txtChannelInfo = uicontrol('Style','text',...
    'Position',[75 17 120 20]);

updateView

% Make figure visble after adding all components
set(H, 'Visible','on');

% Callback functions
    function next(~,~)
        persistant.channelNum = persistant.channelNum + 1;
        updateView
    end

    function previous(~,~)
        persistant.channelNum = persistant.channelNum - 1;
        updateView
    end

    function spectrum(~,~)
        if(strcmp(persistant.options.domain, persistant.DOMAIN_TIME))
            persistant.options.domain = persistant.DOMAIN_FREQUENCY;
            set(persistant.btnSpectrum, 'String', 'Signal');
        else
            persistant.options.domain = persistant.DOMAIN_TIME;
            set(persistant.btnSpectrum, 'String', 'Spectrum');
        end
        updateView
    end

    function handleResize(~,~)
        updateView
    end

    function updateView
        ax = subplot(1, 1, 1, 'Units', 'pixels');
        if(strcmp(persistant.options.domain, persistant.DOMAIN_TIME))
            if(persistant.options.applyDetrend)
                dat = detrend(persistant.channelStream(:, persistant.channelNum));
            else
                dat = persistant.channelStream(:, persistant.channelNum);
            end
            absc = persistant.abscissa;
        else
            if(persistant.options.applyDetrend)
                [dat, absc] = computePSD(detrend(persistant.channelStream(:, persistant.channelNum)), persistant.fs);
            else
                [dat, absc] = computePSD(persistant.channelStream(:, persistant.channelNum), persistant.fs);
            end
        end
        if(strcmp(persistant.options.plotType, persistant.PLOT_TYPE_PLOT))
            p1 = plot(absc, dat, 'LineWidth', persistant.options.lineWidth);
        elseif(strcmp(persistant.options.plotType, persistant.PLOT_TYPE_STEM))
            p1 = stem(absc, dat, 'LineWidth', persistant.options.lineWidth);
        end
        pos = get(ax, 'Position');
        pos(2) = pos(2) + persistant.enlargeFactor / 2;
        pos(4) = pos(4) - persistant.enlargeFactor / 3;
        set(ax, 'Position', pos);
        
        if persistant.channelNum == persistant.numChannels
            set(persistant.btnNext, 'Enable', 'Off');
        else
            set(persistant.btnNext, 'Enable', 'On');
        end
        if persistant.channelNum == 1
            set(persistant.btnPrevious, 'Enable', 'Off');
        else
            set(persistant.btnPrevious, 'Enable', 'On');
        end
        set(persistant.txtChannelInfo, 'String', sprintf('Channel No: %d/%d', persistant.channelNum, persistant.numChannels));
        title(persistant.options.title);
        
        ylabel(persistant.options.yLabel);
        if(~strcmp(persistant.options.domain, persistant.DOMAIN_TIME))
            xlabel('Frequency (Hz)');
        else
            xlabel(persistant.options.xLabel)
        end
        % Create a legend entry
        if(~isempty(persistant.options.legendInfo))
            legendCell{1} = persistant.options.legendInfo{persistant.channelNum};
            legendPlots(1) = p1;
        else
            legendCell = [];
            legendPlots = [];
        end
        
        % Plot cue events if present
        if(~isempty(persistant.options.eventVector) && strcmp(persistant.options.domain, persistant.DOMAIN_TIME))
            hold on
            pa = plot(absc(persistant.options.eventVector), mean(dat), 'ro', 'lineWidth', persistant.options.markerLineWidth);
            hold off;
            legendCell{end+1} = persistant.eventNames{1};
            legendPlots(end+1)  = pa(1);
        end
        % Plot emg onset events if present
        if(~isempty(persistant.options.onsetsVector) && strcmp(persistant.options.domain, persistant.DOMAIN_TIME))
            hold on
            pa = plot(absc(persistant.options.onsetsVector), mean(dat), 'k*', 'lineWidth', persistant.options.markerLineWidth);
            hold off;
            legendCell{end+1} = persistant.eventNames{2};
            legendPlots(end+1)  = pa(1);
        end
        % Plot emg onset events 2 if present
        if(~isempty(persistant.options.onsetsVector2) && strcmp(persistant.options.domain, persistant.DOMAIN_TIME))
            hold on
            pa = plot(absc(persistant.options.onsetsVector2), mean(dat), 'g+', 'lineWidth', persistant.options.markerLineWidth);
            hold off;
            legendCell{end+1} = persistant.eventNames{3};
            legendPlots(end+1)  = pa(1);
        end
        if(~isempty(legendCell))
            legend(legendPlots, legendCell);
        end
    end
end