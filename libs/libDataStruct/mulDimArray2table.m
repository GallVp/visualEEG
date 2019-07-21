function returnTable = mulDimArray2table(onMulDimArray, variableNames, valueName)
%mulDimArray2table Converts a multi-dimensional MATLAB array of form
%   AxBxCx... up to 10 dimensions to a MATLAB table with dimension indices
%   as separate columns for identification.

if nargin < 2
    returnTable = array2table(recursiveDimDestroyer(onMulDimArray)');
elseif nargin < 3
    if iscolumn(variableNames); variableNames = variableNames'; end
    returnTable = array2table(recursiveDimDestroyer(onMulDimArray)');
    varNames = cat(2, variableNames, {'Value'});
    returnTable.Properties.VariableNames = varNames;
else
    if iscolumn(variableNames); variableNames = variableNames'; end
    returnTable = array2table(recursiveDimDestroyer(onMulDimArray)');
    varNames = cat(2, variableNames, valueName);
    returnTable.Properties.VariableNames = varNames;
end

    function returnT = recursiveDimDestroyer(onM)
        sz = size(onM);
        sM = cumprod(sz);
        if sM(end) > length(onM)
            returnT = [];
            for i=1:sz(1)
                returnedDat = recursiveDimDestroyer(squeeze(onM(i, :, :, :, :, :, :, :, :, :)));
                szr = size(returnedDat);
                [~, whichSmall]     = min(szr);
                dimNums = i.*ones(szr);
                dimNums = dimNums(1, :);
                catData = cat(whichSmall, dimNums, returnedDat);
                returnT = [returnT catData];
            end
        else
            [~, whichSmall]     = min(sz);
            dimNums = cumsum(ones(sz));
            returnT = cat(whichSmall, dimNums, onM);
            return
        end
    end
end

