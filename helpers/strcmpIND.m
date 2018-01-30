function [ presentAt ] = strcmpIND( inCell, findCell )
%strcmpIND Finds findCell in inCell and returns an index vector

presentAt = zeros(size(findCell));

for i=1:max(size(findCell))
    ind = find(strcmp(inCell, findCell{i}), 1);
    if(~isempty(ind))
        presentAt(i) = ind;
    end
end

presentAt = presentAt(presentAt ~=0);
end

