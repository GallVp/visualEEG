function cohenD = computeCohensD(vectorA, vectorB)
%computeCohensD Find Cohen's d effect size for two vectors using pooled
%   variance formulation.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.
n1  = sum(~isnan(vectorA));
n2  = sum(~isnan(vectorB));

mean1 = mean(vectorA, 'omitnan');
mean2 = mean(vectorB, 'omitnan');

std1 = std(vectorA, 'omitnan');
std2 = std(vectorB, 'omitnan');

[~, ~, stdpool] = pooledmeanstd(n1, mean1, std1, n2, mean2, std2);

cohenD = round((mean2 - mean1) ./ stdpool, 2);

if nargout < 1
    fprintf('Cohen`s d for %s (%0.2f +|- %0.2f) - %s (%0.2f  +|- %0.2f):%.2f\n', inputname(2), mean2, std2, inputname(1), mean1, std1, cohenD);
end
end

