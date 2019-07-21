function applyToAllFiles(thisFunction, inFolder, andSaveInFolder)
%applyToAllFiles Applies the function to all files.
%   Inputs:
%   1. thisFunction: A handle for a function which takes full file path as
%   input and returns a structure as output.
%   2. inFolder: Path to folder for input files.
%   3. andSaveInFolder: Path to folder for output files.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

EXCLUDED_FILES = {'.DS_Store'};

if nargin < 2
    inFolder        = uigetdir(pwd, 'Select source folder');
    andSaveInFolder = uigetdir(pwd, 'Select destination folder');
end

ouputFolderFiles = processDataFolder(andSaveInFolder);
[inputFolderFiles, ~, inputFolderFilesWithExt] = processDataFolder(inFolder);

[remainingFiles, rI] = setdiff(inputFolderFiles, ouputFolderFiles);
inputFolderFilesWithExt = inputFolderFilesWithExt(rI);

for i = 1:length(inputFolderFilesWithExt)
    processedData = thisFunction(fullfile(inFolder, inputFolderFilesWithExt{i}));
    save(fullfile(andSaveInFolder, remainingFiles{i}), '-struct', 'processedData');
    fprintf('Saved file %s\n', remainingFiles{i});
end

    function [fileNames, fileExts, fileNamesWithExt] = processDataFolder(folderPath)
        fileNames = dir(folderPath);
        fileNames = fileNames(~[fileNames(:).isdir]);
        fileNames = {fileNames.name};
        excludedFiles = strcmpMSC(fileNames, EXCLUDED_FILES);
        fileNames = fileNames(~excludedFiles);
        fileNamesWithExt = fileNames;
        
        [fileNames, fileExts] = cellfun(@cellFilePart, fileNames, 'UniformOutput', 0);
        
        function [fNameWithoutExt, fileExts] = cellFilePart(fName)
            [~, fNameWithoutExt, fileExts] = fileparts(fName);
        end
    end
end