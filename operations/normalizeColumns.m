function [ dataOut ] = normalizeColumns( data )
%normalizeColumns
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.

nRows = size(data, 1);

dataOut = (data - repmat(mean(data), nRows, 1)) ./ repmat(std(data), nRows, 1);

end

