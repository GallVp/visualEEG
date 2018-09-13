function inCell = fillEmpty(inCell, withVal)
%fillEmpty Takes a cell array and replaces empty cells with withVal.
%   The function is inspired by following answer by Guillaume and edited
%   by Stephen Cobeldick.
%
%   https://au.mathworks.com/matlabcentral/answers/325726-how-to-assign-a-
%   nan-to-an-empty-cell-in-a-cell-array-of-cell-array-of-matrix
%
%   In future, this function should support all data types not just cells.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

if nargin < 2
    withVal = nan;
end

inCell(cellfun(@isempty, inCell)) = {withVal};
end