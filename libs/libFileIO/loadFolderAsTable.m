function [folderTable] = loadFolderAsTable(folderPath)
%loadFolderAsTable Loads a folder of mat files saved as
%   subxx_sessyy_movzz.mat and returns a table.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

%% Load a process file names
availableFiles = dir(folderPath);

presentFileTokens = [];

for fileNum = 1 : size(availableFiles)
    subSessMovTokens = regexp(availableFiles(fileNum).name, 'sub([0-9]+)_sess([0-9]+)_mov([0-9]+).mat', 'tokens');
    if(~isempty(subSessMovTokens))
        subSessMovTokens = subSessMovTokens{1};
        presentFileTokens = [presentFileTokens; subSessMovTokens];
    end
end
presentFileTokens = cellfun(@str2double, presentFileTokens);

%% Load and return vmat data
folderTable = struct([]);
for fileNum = 1:size(presentFileTokens)
    folderTable(fileNum).('partNum') = presentFileTokens(fileNum, 1);
    folderTable(fileNum).('sessNum') = presentFileTokens(fileNum, 2);
    folderTable(fileNum).('movNum') = presentFileTokens(fileNum, 3);
    fileName = sprintf('sub%.2d_sess%.2d_mov%.2d.mat', presentFileTokens(fileNum, 1),...
        presentFileTokens(fileNum, 2), presentFileTokens(fileNum, 3));
    loadedFile = load(fullfile(folderPath, fileName));
    fprintf('%s file loaded...\n', fileName);
    fileVars = fieldnames(loadedFile);
    numFileVars = length(fileVars);
    for varNum=1:numFileVars
        folderTable(fileNum).(fileVars{varNum}) = loadedFile.(fileVars{varNum});
    end
end
folderTable = struct2table(folderTable);
end

