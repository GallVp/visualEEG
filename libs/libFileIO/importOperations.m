function [operations, operationArgs] = importOpearions(fileName)
%saveOpearions Loads the operations and the arguments from a comma
%   separated file. Vectors are treated as [a b c].
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

operations      = {};
operationArgs   = {};
numOps          = 0;

fileID = fopen(fileName, 'r');
scriptLine = fgetl(fileID);

while ischar(scriptLine)
    tokens = strsplit(scriptLine, ',');
    numOps = numOps + 1;
    operations{numOps} = tokens{1};
    operationArgs{numOps} = tokens(2:end);
    
    numArgs = size(operationArgs{numOps}, 2);
    for i = 1:numArgs
        test = str2num(strip(operationArgs{numOps}{i}));
        if(~isempty(test))
            operationArgs{numOps}{i} = test;
        else
            operationArgs{numOps}{i} = strip(operationArgs{numOps}{i});
        end
    end
    % Get next script line
    scriptLine = fgets(fileID);
end
fclose(fileID);
end