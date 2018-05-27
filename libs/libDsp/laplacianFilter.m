function [ filteredData ] = laplacianFilter( data, centreChannelNum )
%laplacianFilter Applies laplacian filter to a stream. Channels are across
%   columns and data samples across rows.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

[~, n] = size(data);

filterCofficients = - ones(n, 1) ./ (n - 1);
filterCofficients(centreChannelNum) = 1;

filteredData = data * filterCofficients;
end