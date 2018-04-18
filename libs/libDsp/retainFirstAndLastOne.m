function [ result ] = retainFirstAndLastOne( data )
%retainFirstAndLastOne Retains the first and the last one in a run of ones
%   in a train of 1's and 0's. For example: 1 1 1 1 0 0 0 0 1 results in
%   1 0 0 1 0 0 0 0 1.
%
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See LICENSE in the project root for
%   license information.

result = data;
for i = 2 : (length(data) - 1)
    if(data(i + 1) == 0 || data(i - 1) == 0)
        result(i) = 1 & data(i);
    else
        result(i) = 0;
    end
end
end

