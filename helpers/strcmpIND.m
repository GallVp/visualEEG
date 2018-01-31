function [ presentAt ] = strcmpIND( inCell, findCell )
%strcmpIND Finds findCell in inCell and returns an index vector
%
% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3 of
% the License, or ( at your option ) any later version.  See the
% LICENSE included with this distribution for more information.
presentAt = zeros(size(findCell));

for i=1:max(size(findCell))
    ind = find(strcmp(inCell, findCell{i}), 1);
    if(~isempty(ind))
        presentAt(i) = ind;
    end
end

presentAt = presentAt(presentAt ~=0);
end

