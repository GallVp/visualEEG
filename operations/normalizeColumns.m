function [ dataOut ] = normalizeColumns( data )

nRows = size(data, 1);

dataOut = (data - repmat(mean(data), nRows, 1)) ./ repmat(std(data), nRows, 1);

end

