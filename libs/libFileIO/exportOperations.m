function exportOperations(operations, operationArgs, fileName)
%saveOpearions Saves the operations and the arguments as a comma separated
%   file. Vectors are saved as [a b c].
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.
numOperations = size(operations, 2);
asFormatedText = '';
for i = 1:numOperations
    numArgs = size(operationArgs{i}, 2);
    formatedArgs = '';
    for j = 1:numArgs
        arg = operationArgs{i}{j};
        if(~ischar(arg))
            if(isvector(arg) && length(arg) > 1)
                if(iscolumn(arg))
                    arg = arg';
                end
                arg = sprintf('[%s]', regexprep(num2str(arg),' +',' '));
            else
                arg = num2str(arg);
            end
        end
        if(j == numArgs)
            formatedArgs = sprintf('%s%s', formatedArgs, arg);
        else
            formatedArgs = sprintf('%s%s, ', formatedArgs, arg);
        end
    end
    asFormatedText = sprintf('%s%s, %s\n', asFormatedText, operations{i}, formatedArgs);
end

fileID = fopen(fileName,'w');
fprintf(fileID,'%s', asFormatedText);
fclose(fileID);
end