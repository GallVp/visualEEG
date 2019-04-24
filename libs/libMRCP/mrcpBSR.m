function [pointA, pointB] = mrcpBSR(dataVector, bp1Bounds, bp2Bounds)
%mrcpBSR Performs bounded segmented regression for mrcp segments using
%   particleswarm optimisation.
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.


rng shuffle;

bp2Bounds(2) = length(dataVector) - 1;

lb = [bp1Bounds(1) bp2Bounds(1)];

ub = [bp1Bounds(2) bp2Bounds(2)];

f = @(x)computeCost(dataVector, x);
nvars = 2;

optimOptions = optimoptions('particleswarm', 'SwarmSize', 3 * nvars, 'UseParallel', true, 'Display', 'Iter');

disp('Running the first pass...');
[x1,~,~,~] = particleswarm(f, nvars, lb, ub, optimOptions);
disp('Running the seconds pass...');
[x2,~,~,~] = particleswarm(f, nvars, lb, ub, optimOptions);

c1 = computeCost(dataVector, x1);
c2 = computeCost(dataVector, x2);

if c2 < c1
    x = x2;
else
    x = x1;
end

    function c = computeCost(data, pts)
        ptA = round(pts(1));
        ptB = round(pts(2));
        segmentA = data(1:ptA);
        segmentB = data(ptA+1:ptB);
        segmentC = data(ptB+1:end);
        
        absc = (1:length(data))';
        modelA = mean(segmentA);
        sln = [absc(ptA+1:ptB) ones(length(segmentB), 1)] \ segmentB;
        modelB = sln(1).*absc(ptA+1:ptB) + sln(2);
        sln = [absc(ptB+1:end) ones(length(segmentC), 1)] \ segmentC;
        modelC = sln(1).*absc(ptB+1:end) + sln(2);
        
        c = sum(abs(segmentA - modelA)) ...
            + sum(abs(segmentB - modelB)) ...
            + sum(abs(segmentC - modelC));
    end

pointA = round(x(1));
pointB = round(x(2));
end

