function [P, CI, df, tstat, sd] = repeatedTtest(vectorA, vectorB)
%repeatedTtest Performs repeated measures ttest
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

mean1 = mean(vectorA, 'omitnan');
mean2 = mean(vectorB, 'omitnan');

std1 = std(vectorA, 'omitnan');
std2 = std(vectorB, 'omitnan');


[~, P, CI, STATS]   = ttest(vectorB, vectorA);
df                  = STATS.df;
tstat               = STATS.tstat;
sd                  = STATS.sd;

cohenD = computeCohensD(vectorA, vectorB);

if nargout < 1
    fprintf('Repeated ttest for %s (%0.2f +|- %0.2f) - %s (%0.2f  +|- %0.2f): t(%d) = %0.3f, p = %0.3f, d = %0.2f\n', inputname(2), mean2, std2,...
        inputname(1), mean1, std1, df, tstat, P, cohenD);
end
end