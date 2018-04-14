function [ presentAt ] = strcmpIND( inCell, findCell )
%strcmpIND Finds findCell in inCell and returns an index vector
%
% Copyright (c) <2016> <Usman Rashid>
% Licensed under the MIT License. See License.txt in the project root for 
% license information.

presentAt = zeros(size(findCell));

for i=1:max(size(findCell))
    ind = find(strcmp(inCell, findCell{i}), 1);
    if(~isempty(ind))
        presentAt(i) = ind;
    end
end

presentAt = presentAt(presentAt ~=0);
end

