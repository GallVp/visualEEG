function H = plotChannelsAndEpochs(epochs, fs, options)
%plotChannelsAndEpochs Create a figure and axes showing epoch data.
%   epochs is a matrix in which 1st dimension is the time, 2nd dimension
%   is channels and the 3rd dimension is epochs. This function plots
%   epochs separately for each channel.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

% Available option constants
vars.PLOT_TYPE_PLOT   = 'PLOT';
vars.PLOT_TYPE_STEM   = 'STEM';
vars.DOMAIN_TIME      = 'TIME';
vars.DOMAIN_FREQUENCY = 'FREQUENCY';


% Assign default options
vars.options.plotType         = vars.PLOT_TYPE_PLOT;
vars.options.legendInfo       = [];
vars.options.title            = 'Epoch Data';
vars.options.xLabel           = {'Sample Number'};
vars.options.yLabel           = 'Amplitude';
vars.options.lineWidth        = 1;
vars.options.xShift           = 0;
vars.options.cueEpochs        = [];
vars.options.markerLineWidth  = 2;

switch(nargin)
    case 1
        vars.epochs = epochs;
        vars.fs = [];
        
    case 2
        vars.epochs = epochs;
        vars.fs = fs;
        vars.options.xLabel= {'Time (s)'};
    case 3
        vars.epochs = epochs;
        vars.fs = fs;
        vars.options.xLabel= {'Time (s)'};
        vars.options = assignOptions(options, vars.options);
end

% Startup data selection
vars.totalEpochs = size(vars.epochs, 3);
vars.totalChannels = size(vars.epochs, 2);
vars.epochNum = 1;
vars.channelNum = 1;
vars.domain = vars.DOMAIN_TIME;

% Calculate abscissa from fs
if(isempty(vars.fs))
    vars.abscissa = 1:size(vars.epochs,1);
    vars.abscissa = vars.abscissa - vars.options.xShift;
else
    vars.abscissa = (1:size(vars.epochs,1)) ./ vars.fs;
    vars.abscissa = vars.abscissa - vars.options.xShift;
end

H = figure('Visible','off',...
    'Units', 'pixels',...
    'ResizeFcn',@handleResize,...
    'Name', 'Plot Channel Epochs Tool',...
    'numbertitle','off');

% Startup size
vars.enlargeFactor = 50;
hPos = get(H, 'Position');
hPos(4) = hPos(4) + vars.enlargeFactor;
set(H, 'Position', hPos);

% Create push buttons
vars.btnNext = uicontrol('Style', 'pushbutton', 'String', 'Next',...
    'Position', [300 20 75 20],...
    'Callback', @next);

vars.btnPrevious = uicontrol('Style', 'pushbutton', 'String', 'Previous',...
    'Position', [200 20 75 20],...
    'Callback', @previous);

% Create channel push buttons
vars.btnNextChannel = uicontrol('Style', 'pushbutton', 'String', '>>',...
    'Position', [400 20 25 20],...
    'Callback', @nextChannel);

vars.btnPreviousChannel = uicontrol('Style', 'pushbutton', 'String', '<<',...
    'Position', [150 20 25 20],...
    'Callback', @previousChannel);

% Spectrum button
if(~isempty(vars.fs))
    vars.btnSpectrum = uicontrol('Style', 'pushbutton', 'String', 'Spectrum',...
        'Position', [450 20 75 20],...
        'Callback', @spectrum);
end


% Add a text uicontrol.
vars.txtEpochInfo = uicontrol('Style','text',...
    'Position',[10 25 120 25]);

% First view update
updateView

% Make figure visble after adding all components
set(H, 'Visible','on');

% Event Handlers
    function next(~,~)
        vars.epochNum = vars.epochNum + 1;
        updateView
    end

    function previous(~,~)
        vars.epochNum = vars.epochNum - 1;
        updateView
    end

    function nextChannel(~,~)
        vars.channelNum = vars.channelNum + 1;
        updateView
    end

    function previousChannel(~,~)
        vars.channelNum = vars.channelNum - 1;
        updateView
    end

    function spectrum(~,~)
        if(strcmp(vars.domain, vars.DOMAIN_TIME))
            vars.domain = vars.DOMAIN_FREQUENCY;
            set(vars.btnSpectrum, 'String', 'Signal');
        else
            vars.domain = vars.DOMAIN_TIME;
            set(vars.btnSpectrum, 'String', 'Spectrum');
        end
        updateView
    end

    function handleResize(~,~)
        updateView
    end

% Update view function
    function updateView
        ax = subplot(1, 1, 1, 'Units', 'pixels');
        domainIsTime = strcmp(vars.domain, vars.DOMAIN_TIME);
        if(domainIsTime)
            dat = vars.epochs(:, vars.channelNum,vars.epochNum);
            absc = vars.abscissa;
        else
            [dat, absc] = computePSD(vars.epochs(:, vars.channelNum, vars.epochNum), vars.fs, 1);
        end
        if(strcmp(vars.options.plotType, vars.PLOT_TYPE_PLOT))
            plot(absc, dat)
        elseif(strcmp(vars.options.plotType, vars.PLOT_TYPE_STEM))
            stem(absc, dat)
        end
        hold on;
        % Readjust position
        pos = get(ax, 'Position');
        pos(2) = pos(2) + vars.enlargeFactor / 2;
        pos(4) = pos(4) - vars.enlargeFactor / 3;
        set(ax, 'Position', pos);
        
        % Create a legend entry
        if(~isempty(vars.options.legendInfo))
            legendCell = vars.options.legendInfo{vars.channelNum};
        else
            legendCell = [];
        end
        
        % Plot cue if present
        if(~isempty(vars.options.cueEpochs) && domainIsTime)
            plot(find(vars.options.cueEpochs(:, vars.channelNum, vars.epochNum)) / vars.fs - vars.options.xShift,...
                mean(mean(dat, 2)), 'k+', 'lineWidth', vars.options.markerLineWidth);
            legendCell{end+1} = 'Cue';
        end
        hold off;
        if vars.epochNum == vars.totalEpochs
            set(vars.btnNext, 'Enable', 'Off');
        else
            set(vars.btnNext, 'Enable', 'On');
        end
        
        if vars.epochNum == 1
            set(vars.btnPrevious, 'Enable', 'Off');
        else
            set(vars.btnPrevious, 'Enable', 'On');
        end
        
        % Enable disable channel buttons
        if vars.channelNum == vars.totalChannels
            set(vars.btnNextChannel, 'Enable', 'Off');
        else
            set(vars.btnNextChannel, 'Enable', 'On');
        end
        
        if vars.channelNum == 1
            set(vars.btnPreviousChannel, 'Enable', 'Off');
        else
            set(vars.btnPreviousChannel, 'Enable', 'On');
        end
        
        set(vars.txtEpochInfo, 'String', sprintf('Epoch: %d/%d\nChannel: %d/%d',...
            vars.epochNum, vars.totalEpochs, vars.channelNum, vars.totalChannels));
        
        if(~isempty(legendCell))
            legend(legendCell);
        end
        title(vars.options.title);
        
        ylabel(vars.options.yLabel);
        set(gca, 'LineWidth', vars.options.lineWidth);
        
        if(~domainIsTime)
            xlabel('Frequency (Hz)');
        else
            xlabel(vars.options.xLabel);
        end
    end
end