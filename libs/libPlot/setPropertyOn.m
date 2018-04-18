function setPropertyOn(axH, searchString, propertyName, propertyValue)
%ginputWithPlot Sets specified property on all controls of the parent
%   figure of the axis axH.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

a = findobj(axH.Parent, '-regexp', 'Tag', searchString);
for i=1:length(a)
    set(a, propertyName, propertyValue);
end
end

