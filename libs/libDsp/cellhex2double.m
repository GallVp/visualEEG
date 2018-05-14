function [ outMat ] = cellhex2double( inCell, numBytes )
%cellhex2double Converts a cell of hex values to double
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.
[m, n] = size(inCell);
outMat = zeros(m, n);
progress = 0;
for i=1:m
    for j=1:n
        outMat(i,j) = strhex2double(inCell{i,j}, numBytes);
    end
    lastProgress = progress;
    progress = round(i / m * 100);
    if(lastProgress ~= progress)
        fprintf('Hex conversion progress: %d%%\n', progress);
    end
end
end