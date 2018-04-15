function [ dataOut ] = normalizeColumns( data )
%normalizeColumns
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

nRows = size(data, 1);

dataOut = (data - repmat(mean(data), nRows, 1)) ./ repmat(std(data), nRows, 1);

end

