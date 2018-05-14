function numLines = numLinesInCSV(filename)
%numLinesInCSV Finds the number of lines in a csv file. Based on reply of 
%   Azzi Abdelmalek on post: https://au.mathworks.com/matlabcentral/
%   answers/106431-calculating-total-number-of-lines-in-a-file-opened-in-
%   matlab#answer_115448
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.
fileId = fopen(filename);
fileData={};

while ~feof(fileId)
    thisline = fgetl(fileId);
    
    if ~ischar(thisline)
        break; 
    end
    fileData{end+1,1} = thisline;
end
fclose(fileId);

numLines = numel(fileData);
end

