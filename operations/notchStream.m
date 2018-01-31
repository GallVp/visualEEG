function [ outSignal ] = notchStream( inSignal, fs, notchWin )
%lowPassStream Notches the signsl(s) using a second order butterworth
% zero phase filter with 'notchWin'~[49 51].
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.

if nargin < 3
    notchWin = [49 51];
end

FILTER_ORDER = 2;
[bb, aa] = butter(FILTER_ORDER, notchWin/(fs/2), 'stop');
outSignal = filtfilt(bb, aa, inSignal);

end

