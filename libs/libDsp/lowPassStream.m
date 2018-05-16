function [ outSignal ] = lowPassStream( inSignal, fs, lpCutOff )
%lowPassStream Low passes the signal(s) using a second order butterworth
%   zero phase filter with cuttOff at 'lpCutOff'~40.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

if nargin < 3
    lpCutOff = 40;
end

FILTER_ORDER = 2;

fcLow = lpCutOff;
[bb, aa] = butter(FILTER_ORDER, fcLow/(fs/2), 'low');
outSignal = filtfilt(bb, aa, inSignal);

end

