function [filteredData] = filterStream(data, fs, order, fcLow, fcHigh, zeroPhase)
% filterStream Apply low and high pass filter to a stream of data.
%
%
% Default Parameters:
% zeroPhase = 1; If true, filtfilt is used instead of filter.
% fcHigh = 0.05
% fcLow = 1
% order = 2
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.

if (nargin < 3)
    zeroPhase = 1;
    fcHigh = 0.05;
    fcLow = 1;
    order = 2;
elseif (nargin < 4)
    zeroPhase = 1;
    fcHigh = 0.05;
    fcLow = 1;
elseif (nargin < 5)
    zeroPhase = 1;
    fcHigh = 0.05;
elseif (nargin < 6)
    zeroPhase = 1;
end

[b, a]  = butter(order, fcLow/(fs/2), 'low');
[bb, aa] = butter(order, fcHigh/(fs/2), 'high');

if(zeroPhase)
    filteredData = filtfilt(b,a, data);
    filteredData = filtfilt(bb,aa,filteredData);
else
    filteredData = filter(b,a, data);
    filteredData = filter(bb,aa,filteredData);
end