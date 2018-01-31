function [ X, f ] = computeFFT( x, fs )
%computeFFT takes the fft of given data and returns one sided amplitude
% spectrum alongwith frequency vector.
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.

Fs = fs;              % Sampling frequency
T = 1/Fs;             % Sampling period
L = length(x);        % Length of signal
t = (0:L-1)*T;        % Time vector
f = Fs*(0:(floor(L/2)))/L;

X = fft(x);
P2 = abs(X/L);
P1 = P2(1:floor(L/2)+1,:);
P1(2:end-1,:) = 2*P1(2:end-1,:);

X = P1;
end

