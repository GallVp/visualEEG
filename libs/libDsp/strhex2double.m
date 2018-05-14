function [ thisDouble ] = strhex2double( thisStr, withNumBytes )
%strhex2double Takes a single hex str in twos complement format and
%   generates a double. MSD should be on the left.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.
thisDouble = uint64(hex2dec(thisStr));

maxNum = uint64(2^(withNumBytes * 8 - 1) - 1);
% Twos complement operation
sigValue = bitshift(thisDouble , -(withNumBytes * 8 - 1));
if (sigValue == 1)
    thisDouble = bitand(thisDouble, maxNum);
    thisDouble = bitcmp(thisDouble);
    thisDouble = bitand(thisDouble, maxNum);
    thisDouble = -double(thisDouble + 1);
else
    thisDouble = double(thisDouble);
end