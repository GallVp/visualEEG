function [ outputData ] = spatialFilterSstData( inputData, filterCoffs )
%spatialFilterSstData Takes data in Sst format and applies spatial filter.

% Copyright (c) <2016> <Usman Rashid>
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% LICENSE included with this distribution for more information.

[m, n, o] = size(inputData);
if (length(filterCoffs) ~= n)
    throw(MException('dsp:filter:coffsNumMismatch'));
end

outputData = zeros(m, 1, o);

for i = 1:o
    outputData(:,:,i) = inputData(:,:,i) * filterCoffs;
end
end

