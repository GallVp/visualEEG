function isEqual = opCompare(oldOps, oldOpArgs, newOps, newOpArgs)
%opCompare Compares two sets of operations and their arguments to find if
%   the two are equal.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

isEqual             = 0; % By default return 0

cmpResults          = strcmp(oldOps, newOps);

if(sum(cmpResults) ~= length(cmpResults)) % Simply compare operation names
    return;
else % If operation names are in the same sequence then compare their arguments
    for i=1:length(oldOps)
        areThey = isequal(oldOpArgs{i}, newOpArgs{i});
        if ~areThey
            return;
        end
    end
end

isEqual             = 1; % Return 1 if all checks passed
end