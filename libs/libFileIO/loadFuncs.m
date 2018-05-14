function [funcNames] = loadFuncs(folderName)
%loadFuncs Creates a cell array of function names from *.m files in a
%   directory.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.


FUNC_EXT = '.m';

fileNames = dir(folderName);
funcNames = cell(size(fileNames, 1), 1);
for i=1:size(fileNames, 1)
    [~, funcName, ext] = fileparts(fileNames(i).name);
    if(strcmp(ext, FUNC_EXT))
        funcNames{i} = funcName;
    end
end

funcNames = funcNames(~cellfun('isempty', funcNames));
end

