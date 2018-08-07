function EEG = buildEEGStruct(data, fs, channelNames, locFile, options)
%buildEEGStruct Builds eeglab `EEG' struct from a minimum list of
%   arguments. To avoid conflict with the GNU GPL license, a location file
%   loaded with eeglab `readlocs' function has to be provided as an
%   argument. First four arguments are a must, while remaining are
%   optional.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

%% Defaults
if nargin < 4
    error('data, fs, channelNames, locFile must be specified...');
elseif nargin < 5
    options = [];
end

% Default options
defaultOptions.eventVector = [];
defaultOptions.eventTypes  = [];
defaultOptions.timeVect    = [];

options = assignOptions(options, defaultOptions);

%% Constants

%% Prepare channel locs
chanLocs = locFile(strcmpIND(transpose({locFile(:).labels}), channelNames, 0));
urChanLocs = locFile(strcmpIND(transpose({locFile(:).labels}), channelNames, 0));

%% Prepare data variable
[m, n, ~] = size(data);

% Number of samples should be larger than number of channels. In eeglab,
% first dimension is channels
if m > n && length(channelNames) == n
    data = permute(data, [2 1 3]);
end

%% Prepare timeVect
if isempty(options.timeVect)
    options.timeVect = (1:1:size(data, 2)) ./ fs;
end

%% Prepare EEG struct
EEG.setname                         = [];
EEG.filename                        = [];
EEG.filepath                        = [];
EEG.subject                         = [];
EEG.group                           = [];
EEG.condition                       = [];
EEG.session                         = [];
EEG.comments                        = [];
EEG.nbchan                          = size(data, 1);
EEG.trials                          = size(data, 3);
EEG.pnts                            = size(data, 2);
EEG.srate                           = fs;
EEG.xmin                            = 1 / EEG.srate;
EEG.xmax                            = EEG.pnts / EEG.srate;
EEG.times                           = options.timeVect;
EEG.data                            = data;
EEG.icaact                          = [];
EEG.icawinv                         = [];
EEG.icasphere                       = [];
EEG.icaweights                      = [];
EEG.icachansind                     = [];
EEG.chanlocs                        = chanLocs;
EEG.urchanlocs                      = urChanLocs;
EEG.chaninfo                        = [];
EEG.ref                             = 'common';
EEG.event                           = eegLabEventStruct(options.eventVector, options.eventTypes);
EEG.urevent                         = eegLabEventStruct(options.eventVector, options.eventTypes);
EEG.eventdescription                = {};
EEG.epoch                           = [];
EEG.epochdescription                = {};
EEG.reject                          = [];
EEG.stats                           = [];
EEG.specdata                        = [];
EEG.specicaact                      = [];
EEG.splinefile                      = '';
EEG.icasplinefile                   = '';
EEG.dipfit                          = [];
EEG.history                         = '';
EEG.saved                           = 'no';
EEG.etc                             = [];
end

