function H = plotChannelData(channelStream, fs, options)
% PLOTCHANNELDATA Creates a figure and axes showing channelStream Data.
%   channelStream is a matrix in which 1st dimension is the time and
%   second dimension is the channels.
%
%   Available options:
%   options.plotType         = vars.PLOT_TYPE_PLOT;
%   options.legendInfo       = [];
%   options.title            = 'Channel Data';
%   options.xLabel           = {'Sample Number'};
%   options.yLabel           = 'Amplitude';
%   options.lineWidth        = 1;
%   options.markerLineWidth  = 1;
%   options.domain           = vars.DOMAIN_TIME;
%   options.eventVector      = [];
%   options.onsetsVector     = [];
%   options.onsetsVector2    = [];
%   options.applyDetrend     = 1;
%   options.xShift           = 0;
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

% Available option constants
vars.PLOT_TYPE_PLOT   = 'PLOT';
vars.PLOT_TYPE_STEM   = 'STEM';
vars.DOMAIN_TIME      = 'TIME';
vars.DOMAIN_FREQUENCY = 'FREQUENCY';
vars.DOMAIN_STAT      = 'STAT';
vars.NUM_HIST_BINS    = 100;
vars.eventNames = {'Cue', 'Detected onsets', 'Selected onsets'};

% Assign default options
vars.options.plotType         = vars.PLOT_TYPE_PLOT;
vars.options.legendInfo       = [];
vars.options.title            = 'Channel Data';
vars.options.xLabel           = {'Sample Number'};
vars.options.yLabel           = 'Amplitude';
vars.options.lineWidth        = 1;
vars.options.markerLineWidth  = 1;
vars.options.domain           = vars.DOMAIN_TIME;
vars.options.eventVector      = [];
vars.options.onsetsVector     = [];
vars.options.onsetsVector2    = [];
vars.options.applyDetrend     = 1;
vars.options.xShift           = 0;

switch(nargin)
    case 1
        vars.channelStream = channelStream;
        vars.fs = [];
        
    case 2
        vars.channelStream = channelStream;
        vars.fs = fs;
        vars.options.xLabel= {'Time (s)'};
    case 3
        vars.channelStream = channelStream;
        vars.fs = fs;
        vars.options.xLabel= {'Time (s)'};
        vars.options = assignOptions(options, vars.options);
end

vars.numChannels = size(vars.channelStream, 2);
vars.channelNum = 1;

% Calculate abscissa from fs
if(isempty(vars.fs))
    vars.abscissa = 1:size(vars.channelStream, 1);
    vars.abscissa = vars.abscissa - vars.options.xShift;
else
    vars.abscissa = (1:size(vars.channelStream, 1)) ./ fs;
    vars.abscissa = vars.abscissa - vars.options.xShift;
end

H = figure('Visible', 'off',...
    'Units', 'pixels',...
    'ResizeFcn', @handleResize,...
    'Name', 'Plot Channels Tool',...
    'numbertitle','off');
vars.enlargeFactor = 50;
hPos = get(H, 'Position');
hPos(4) = hPos(4) + vars.enlargeFactor;
set(H, 'Position', hPos);

% Create push buttons
vars.btnNext = uicontrol('Style', 'pushbutton', 'String', 'Next',...
    'Position', [250 20 75 20],...
    'Callback', @next);

vars.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
    'Position', [150 20 75 20],...
    'Callback', @previous);
if(~isempty(vars.fs))
    vars.btnSpectrum = uicontrol('Style', 'pushbutton', 'String', 'Spectrum',...
        'Position', [350 20 75 20],...
        'Callback', @spectrum);
end

vars.btnHist = uicontrol('Style', 'pushbutton', 'String', 'Histogram',...
    'Position', [450 20 75 20],...
    'Callback', @histogram);


% Add a text uicontrol.
vars.txtChannelInfo = uicontrol('Style','text',...
    'Position',[25 20 120 20]);

updateView

% Make figure visble after adding all components
set(H, 'Visible','on');

% Callback functions
    function next(~,~)
        vars.channelNum = vars.channelNum + 1;
        updateView
    end

    function previous(~,~)
        vars.channelNum = vars.channelNum - 1;
        updateView
    end

    function spectrum(~,~)
        if(strcmp(vars.options.domain, vars.DOMAIN_TIME) || strcmp(vars.options.domain, vars.DOMAIN_STAT))
            vars.options.domain = vars.DOMAIN_FREQUENCY;
            set(vars.btnSpectrum, 'String', 'Signal');
            set(vars.btnHist, 'String', 'Histogram');
        else
            vars.options.domain = vars.DOMAIN_TIME;
            set(vars.btnSpectrum, 'String', 'Spectrum');
        end
        updateView
    end

    function histogram(~,~)
        if(strcmp(vars.options.domain, vars.DOMAIN_TIME) || strcmp(vars.options.domain, vars.DOMAIN_FREQUENCY))
            vars.options.domain = vars.DOMAIN_STAT;
            if(~isempty(vars.fs))
                set(vars.btnSpectrum, 'String', 'Spectrum');
            end
            set(vars.btnHist, 'String', 'Signal');
        else
            vars.options.domain = vars.DOMAIN_TIME;
            set(vars.btnHist, 'String', 'Histogram');
        end
        updateView
    end

    function handleResize(~,~)
        updateView
    end

    function updateView
        ax = subplot(1, 1, 1, 'Units', 'pixels');
        if(strcmp(vars.options.domain, vars.DOMAIN_TIME))
            if(vars.options.applyDetrend)
                dat = detrend(vars.channelStream(:, vars.channelNum));
            else
                dat = vars.channelStream(:, vars.channelNum);
            end
            absc = vars.abscissa;
        elseif(strcmp(vars.options.domain, vars.DOMAIN_FREQUENCY))
            if(vars.options.applyDetrend)
                [dat, absc] = computePSD(detrend(vars.channelStream(:, vars.channelNum)), vars.fs);
            else
                [dat, absc] = computePSD(vars.channelStream(:, vars.channelNum), vars.fs);
            end
        else
            if(vars.options.applyDetrend)
                [dat, absc] = hist(detrend(vars.channelStream(:, vars.channelNum)), vars.NUM_HIST_BINS);
            else
                [dat, absc] = hist(vars.channelStream(:, vars.channelNum), vars.NUM_HIST_BINS);
            end
        end
        if(strcmp(vars.options.plotType, vars.PLOT_TYPE_PLOT))
            p1 = plot(absc, dat, 'LineWidth', vars.options.lineWidth);
        elseif(strcmp(vars.options.plotType, vars.PLOT_TYPE_STEM))
            p1 = stem(absc, dat, 'LineWidth', vars.options.lineWidth);
        end
        pos = get(ax, 'Position');
        pos(2) = pos(2) + vars.enlargeFactor / 2;
        pos(4) = pos(4) - vars.enlargeFactor / 3;
        set(ax, 'Position', pos);
        
        if vars.channelNum == vars.numChannels
            set(vars.btnNext, 'Enable', 'Off');
        else
            set(vars.btnNext, 'Enable', 'On');
        end
        if vars.channelNum == 1
            set(vars.btnPrevious, 'Enable', 'Off');
        else
            set(vars.btnPrevious, 'Enable', 'On');
        end
        set(vars.txtChannelInfo, 'String', sprintf('Channel No: %d/%d', vars.channelNum, vars.numChannels));
        title(vars.options.title);
        
        ylabel(vars.options.yLabel);
        if(~strcmp(vars.options.domain, vars.DOMAIN_TIME))
            xlabel('Frequency (Hz)');
        else
            xlabel(vars.options.xLabel)
        end
        % Create a legend entry
        if(~isempty(vars.options.legendInfo))
            legendCell{1} = vars.options.legendInfo{vars.channelNum};
            legendPlots(1) = p1;
        else
            legendCell = [];
            legendPlots = [];
        end
        
        % Plot cue events if present
        if(~isempty(vars.options.eventVector) && strcmp(vars.options.domain, vars.DOMAIN_TIME))
            hold on
            pa = plot(absc(vars.options.eventVector), mean(dat), 'ro', 'lineWidth', vars.options.markerLineWidth);
            hold off;
            legendCell{end+1} = vars.eventNames{1};
            legendPlots(end+1)  = pa(1);
        end
        % Plot emg onset events if present
        if(~isempty(vars.options.onsetsVector) && strcmp(vars.options.domain, vars.DOMAIN_TIME))
            hold on
            pa = plot(absc(vars.options.onsetsVector), mean(dat), 'k*', 'lineWidth', vars.options.markerLineWidth);
            hold off;
            legendCell{end+1} = vars.eventNames{2};
            legendPlots(end+1)  = pa(1);
        end
        % Plot emg onset events 2 if present
        if(~isempty(vars.options.onsetsVector2) && strcmp(vars.options.domain, vars.DOMAIN_TIME))
            hold on
            pa = plot(absc(vars.options.onsetsVector2), mean(dat), 'g+', 'lineWidth', vars.options.markerLineWidth);
            hold off;
            legendCell{end+1} = vars.eventNames{3};
            legendPlots(end+1)  = pa(1);
        end
        if(~isempty(legendCell))
            legend(legendPlots, legendCell);
        end
    end
end