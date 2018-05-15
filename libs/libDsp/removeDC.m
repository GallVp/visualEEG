function [ outSignal ] = removeDC( inSignal, fs, dcCutOff )
%removeDC Removes dc from the signsl(s) using a second order butterworth
%   zero phase filter with cuttOff at 'dcCutOff'~0.05.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

if nargin < 3
    dcCutOff = 0.05;
end

FILTER_ORDER = 2;

fcHigh = dcCutOff;
[bb, aa] = butter(FILTER_ORDER, fcHigh/(fs/2), 'high');
outSignal = filtfilt(bb, aa, inSignal);

end

