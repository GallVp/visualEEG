function [simMeasure] = cosineSimilarity(vectorA, vectorB)
%cosineSimilarity Computes cosine similarity between two vectors of equal
%   length.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.
simMeasure = dot(vectorA, vectorB) / (norm(vectorA) * norm(vectorB));
end

