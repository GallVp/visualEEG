function [ X, f ] = computeFFT( x, fs )
%computeFFT takes the fft of given data and returns one sided amplitude
%   spectrum alongwith frequency vector.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

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

