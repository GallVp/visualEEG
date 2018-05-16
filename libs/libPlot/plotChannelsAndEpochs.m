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
persistant.PLOT_TYPE_PLOT   = 'PLOT';
persistant.PLOT_TYPE_STEM   = 'STEM';
persistant.DOMAIN_TIME      = 'TIME';
persistant.DOMAIN_FREQUENCY = 'FREQUENCY';


% Assign default options
persistant.options.plotType         = persistant.PLOT_TYPE_PLOT;
persistant.options.legendInfo       = [];
persistant.options.title            = 'Epoch Data';
persistant.options.xLabel           = {'Sample Number'};
persistant.options.yLabel           = 'Amplitude';
persistant.options.lineWidth        = 1;
persistant.options.xShift           = 0;
persistant.options.cueEpochs        = [];
persistant.options.markerLineWidth  = 2;

switch(nargin)
    case 1
        persistant.epochs = epochs;
        persistant.fs = [];
        
    case 2
        persistant.epochs = epochs;
        persistant.fs = fs;
        persistant.options.xLabel= {'Time (s)'};
    case 3
        persistant.epochs = epochs;
        persistant.fs = fs;
        persistant.options.xLabel= {'Time (s)'};
        persistant.options = assignOptions(options, persistant.options);
end

% Startup data selection
persistant.totalEpochs = size(persistant.epochs, 3);
persistant.totalChannels = size(persistant.epochs, 2);
persistant.epochNum = 1;
persistant.channelNum = 1;
persistant.domain = persistant.DOMAIN_TIME;

% Calculate abscissa from fs
if(isempty(persistant.fs))
    persistant.abscissa = 1:size(persistant.epochs,1);
    persistant.abscissa = persistant.abscissa - persistant.options.xShift;
else
    persistant.abscissa = (1:size(persistant.epochs,1)) ./ persistant.fs;
    persistant.abscissa = persistant.abscissa - persistant.options.xShift;
end

H = figure('Visible','off',...
    'Units', 'pixels',...
    'ResizeFcn',@handleResize,...
    'Name', 'Plot Channel Epochs Tool',...
    'numbertitle','off');

% Startup size
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

% Create channel push buttons
persistant.btnNextChannel = uicontrol('Style', 'pushbutton', 'String', '>>',...
    'Position', [400 20 25 20],...
    'Callback', @nextChannel);

persistant.btnPreviousChannel = uicontrol('Style', 'pushbutton', 'String', '<<',...
    'Position', [150 20 25 20],...
    'Callback', @previousChannel);

% Spectrum button
if(~isempty(persistant.fs))
    persistant.btnSpectrum = uicontrol('Style', 'pushbutton', 'String', 'Spectrum',...
        'Position', [450 20 75 20],...
        'Callback', @spectrum);
end


% Add a text uicontrol.
persistant.txtEpochInfo = uicontrol('Style','text',...
    'Position',[10 20 120 25]);

% First view update
updateView

% Make figure visble after adding all components
set(H, 'Visible','on');

% Event Handlers
    function next(~,~)
        persistant.epochNum = persistant.epochNum + 1;
        updateView
    end

    function previous(~,~)
        persistant.epochNum = persistant.epochNum - 1;
        updateView
    end

    function nextChannel(~,~)
        persistant.channelNum = persistant.channelNum + 1;
        updateView
    end

    function previousChannel(~,~)
        persistant.channelNum = persistant.channelNum - 1;
        updateView
    end

    function spectrum(~,~)
        if(strcmp(persistant.domain, persistant.DOMAIN_TIME))
            persistant.domain = persistant.DOMAIN_FREQUENCY;
            set(persistant.btnSpectrum, 'String', 'Signal');
        else
            persistant.domain = persistant.DOMAIN_TIME;
            set(persistant.btnSpectrum, 'String', 'Spectrum');
        end
        updateView
    end

    function handleResize(~,~)
        updateView
    end

% Update view function
    function updateView
        ax = subplot(1, 1, 1, 'Units', 'pixels');
        domainIsTime = strcmp(persistant.domain, persistant.DOMAIN_TIME);
        if(domainIsTime)
            dat = persistant.epochs(:, persistant.channelNum,persistant.epochNum);
            absc = persistant.abscissa;
        else
            [dat, absc] = computePSD(persistant.epochs(:, persistant.channelNum, persistant.epochNum), persistant.fs, 1);
        end
        if(strcmp(persistant.options.plotType, persistant.PLOT_TYPE_PLOT))
            plot(absc, dat)
        elseif(strcmp(persistant.options.plotType, persistant.PLOT_TYPE_STEM))
            stem(absc, dat)
        end
        hold on;
        % Readjust position
        pos = get(ax, 'Position');
        pos(2) = pos(2) + persistant.enlargeFactor / 2;
        pos(4) = pos(4) - persistant.enlargeFactor / 3;
        set(ax, 'Position', pos);
        
        % Create a legend entry
        if(~isempty(persistant.options.legendInfo))
            legendCell = persistant.options.legendInfo{persistant.channelNum};
        else
            legendCell = [];
        end
        
        % Plot cue if present
        if(~isempty(persistant.options.cueEpochs) && domainIsTime)
            plot(find(persistant.options.cueEpochs(:, persistant.channelNum, persistant.epochNum)) / persistant.fs - persistant.options.xShift,...
                mean(mean(dat, 2)), 'k+', 'lineWidth', persistant.options.markerLineWidth);
            legendCell{end+1} = 'Cue';
        end
        hold off;
        if persistant.epochNum == persistant.totalEpochs
            set(persistant.btnNext, 'Enable', 'Off');
        else
            set(persistant.btnNext, 'Enable', 'On');
        end
        
        if persistant.epochNum == 1
            set(persistant.btnPrevious, 'Enable', 'Off');
        else
            set(persistant.btnPrevious, 'Enable', 'On');
        end
        
        % Enable disable channel buttons
        if persistant.channelNum == persistant.totalChannels
            set(persistant.btnNextChannel, 'Enable', 'Off');
        else
            set(persistant.btnNextChannel, 'Enable', 'On');
        end
        
        if persistant.channelNum == 1
            set(persistant.btnPreviousChannel, 'Enable', 'Off');
        else
            set(persistant.btnPreviousChannel, 'Enable', 'On');
        end
        
        set(persistant.txtEpochInfo, 'String', sprintf('Epoch: %d/%d\nChannel: %d/%d',...
            persistant.epochNum, persistant.totalEpochs, persistant.channelNum, persistant.totalChannels));
        
        if(~isempty(legendCell))
            legend(legendCell);
        end
        title(persistant.options.title);
        
        ylabel(persistant.options.yLabel);
        set(gca, 'LineWidth', persistant.options.lineWidth);
        
        if(~domainIsTime)
            xlabel('Frequency (Hz)');
        else
            xlabel(persistant.options.xLabel);
        end
    end
end