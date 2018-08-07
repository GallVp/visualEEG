function [aucValue, youdenIndex, youdenValue] = plotROC(tpr, fpr, figHandle, plotAll)
%plotROC Plot ROC using true positive rate (tpr) and false positive rate
%   (fpr). Both tpr and fpr are assumed column vectors.
%
%   The algorithm used in this function to construct the ROC is based on
%   convex hull, refer to Fawcett, T., ``An introduction to ROC
%   analysis'', 2006.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

if nargin < 3
    figHandle = figure;
    plotAll = 1;
elseif nargin < 4
    figHandle = figure;
end

figure(figHandle);

% Make column if row
if isrow(tpr);tpr = tpr';end
if isrow(fpr);fpr = fpr';end

% Exclude "useless" points
tpr__           = tpr;
fpr__           = fpr;
tpr_            = tpr(tpr >= fpr);
fpr_            = fpr(tpr >= fpr);

tpr             = tpr_;
fpr             = fpr_;

tpr_            = tpr__;
fpr_            = fpr__;

% Append (0, 0); (1, 1); and (100, 0) points for finding convex hull
tpr             = [tpr;0;100;0];
fpr             = [fpr;0;100;100];

% Find roc points using the convex hull method
rocPoints                   = convhull(tpr, fpr);
rocPoints(end)              = [];
rocPoints(fpr(rocPoints) == 100 & tpr(rocPoints) == 0) = [];
[~, I]                      = sort(fpr(rocPoints));
rocPoints                   = rocPoints(I);

% AUC score
aucValue                    = aucScore(tpr(rocPoints), fpr(rocPoints));

% Compute Youden Index
[youdenValue, youdenIndex]  = max(tpr_ - fpr_);


% Plot the curve
plot([0, 100], [0, 100], '--');
hold on;
if(~isempty(rocPoints))
    plot(fpr(rocPoints), tpr(rocPoints), 'r-')
end
xlabel('FPR (%)');
ylabel('TPR (%)');
set(gca, 'TickLength', [0 0]);
box off;

% Plot Youden point
if(~isempty(youdenIndex))
    plot(fpr_(youdenIndex), tpr_(youdenIndex), 'ro', 'MarkerSize', 12);
end

% Plot all the points if asked for, excluding the bottom right appended point
if plotAll
    plot(fpr_, tpr_, 'k+', 'MarkerSize', 12);
end

title(sprintf('AUROC: %0.2f, YI: %0.2f', aucValue, youdenValue))
end
