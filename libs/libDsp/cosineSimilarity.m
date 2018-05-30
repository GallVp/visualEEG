function [simMeasure] = cosineSimilarity(matrixA, matrixB)
%cosineSimilarity Computes cosine similarity between two vectors of equal
%   length or two matrices along their columns.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.
simMeasure = dot(matrixA, matrixB) ./ (sqrt(sum(matrixA .* matrixA)) .* sqrt(sum(matrixB .* matrixB)));
end

