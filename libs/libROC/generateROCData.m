function [tpr, fpr, paramMat] = generateROCData(funcAlias, paramLB, paramUB, paramStep, nSim)
%generateROCData Takes a function alias similar to fminunc along with
%   vectors of lower bounds, upper bounds and step for parameters. Func
%   alias should accept one argument which is the parameter vector and
%   return two values: tpr, fpr.
%
%   nSim is 0 by default which means all the samples in the sampling space
%   will be considered. if nSim > n(sampleSpace), nSim = n(sampleSpace).
%   Only unique samples are considered.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

if nargin < 5
    nSim = 0;
end

numParam        = length(paramLB);
paramSpaceSize  = floor((paramUB - paramLB) ./ paramStep) + 1;

if nSim > prod(paramSpaceSize) || nSim == 0
    nSim = prod(paramSpaceSize);
end

if nSim == prod(paramSpaceSize)
    tpr         = NaN .* ones(nSim, 1);
    fpr         = NaN .* ones(nSim, 1);
    paramMat    = NaN .* ones(nSim, numParam);
    for i = 1:nSim
        [paramChoice{1:numParam}]   = ind2sub(paramSpaceSize, i);
        paramChoiceMat              = cell2mat(paramChoice);
        chosenParam                 = paramLB + (paramChoiceMat - 1) .* paramStep;
        [tpr(i, :), fpr(i, :)]      = funcAlias(chosenParam);
        paramMat(i, :)              = chosenParam;
        fprintf('ROC data simulations performed %d/%d\n', i, nSim);
    end
else
    a = randperm(prod(paramSpaceSize));
    simPerm = a(1:nSim);
    tpr         = NaN .* ones(length(simPerm), 1);
    fpr         = NaN .* ones(length(simPerm), 1);
    paramMat    = NaN .* ones(length(simPerm), numParam);
    for i=1:length(simPerm)
        [paramChoice{1:numParam}]   = ind2sub(paramSpaceSize, simPerm(i));
        paramChoiceMat              = cell2mat(paramChoice);
        chosenParam                 = paramLB + (paramChoiceMat - 1) .* paramStep;
        [tpr(i, :), fpr(i, :)]      = funcAlias(chosenParam);
        paramMat(i, :)              = chosenParam;
        fprintf('ROC data simulations performed %d/%d\n', i, length(simPerm));
    end
end
end