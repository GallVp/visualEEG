function [ outSignal ] = notchStream( inSignal, fs, notchWin )
%lowPassStream Notches the signsl(s) using a second order butterworth
%zero phase filter with 'notchWin'~[49 51].

if nargin < 3
    notchWin = [49 51];
end

FILTER_ORDER = 2;
[bb, aa] = butter(FILTER_ORDER, notchWin/(fs/2), 'stop');
outSignal = filtfilt(bb, aa, inSignal);

end

