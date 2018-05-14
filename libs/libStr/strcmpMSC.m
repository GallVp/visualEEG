function [ isPresent ] = strcmpMSC( inCell, findCell )
%STRCMPMSC Finds findCell in inCell and returns a logical vector
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

isPresent = zeros(size(inCell));

for i=1:max(size(findCell))
    isPresent = isPresent | strcmp(inCell, findCell{i});
end
end

