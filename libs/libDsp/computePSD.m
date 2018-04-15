function [ X, f ] = computePSD( x, fs )
%computePSD Estimates power spectral density pwelch. This code is written
%   in accordance with the recommendations of Hanspeter Schmid, "How to use
%   the FFT and Matlab?s pwelch function for signal and
%   noise simulations and measurements", 2011.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

na = 16;
nx = length(x);
w = hanning(floor(na/nx));

[X, f] = pwelch(x, w, 0, [], fs);

X = 10.*log10(X);
end

