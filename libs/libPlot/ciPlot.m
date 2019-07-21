function ciPlot(matA, matB, inputOptions)
%ciPlot Plots mean and confidence intervals for rows across columns of matA
%   and matB along with the difference wave.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.


ciLevelSample = 1.96;

defaultOptions.isMatched    = 1;
defaultOptions.plotDiff     = 1;
defaultOptions.legend       = [];
defaultOptions.colorCode    = 'r';

if nargin < 2
    matB = [];
    options = defaultOptions;
elseif nargin < 3
    options = defaultOptions;
else
    options = assignOptions(inputOptions, defaultOptions);
end



meanA = mean(matA, 2, 'omitnan');
meanB = mean(matB, 2, 'omitnan');

stdA = std(matA, 0, 2, 'omitnan');
stdB = std(matB, 0, 2, 'omitnan');

nA = size(matA, 2);
nB = size(matB, 2);

if isempty(matB)
    ciLevel = 1.96;
else
    if options.isMatched
        ciLevel = tinv(0.975, nA - 1);
    else
        ciLevel = tinv(0.975, nA + nB - 2);
    end
end

ciA = ciLevelSample .* stdA ./ sqrt(nA);
ciB = ciLevelSample .* stdB ./ sqrt(nB);

x = 1:length(meanA);

meanA = meanA';
stdA = stdA';
ciA = ciA';

meanB = meanB';
stdB = stdB';
ciB = ciB';


if ~isempty(matB)
    if options.plotDiff
        ax(1) = subplot(2, 1, 1);
    end
    p1 = plot(x, meanA, 'b-', 'LineWidth', 1.5);
    hold on;
    plot([x(1) x(end)], [0 0], 'k--', 'LineWidth', 1);
    fill([x fliplr(x)],[meanA-ciA fliplr(meanA+ciA)], 'b', 'EdgeColor', [1 1 1], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    
    p2 = plot(x, meanB, 'r-', 'LineWidth', 1.5);
    fill([x fliplr(x)],[meanB-ciB fliplr(meanB+ciB)], 'r', 'EdgeColor', [1 1 1], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    hold off;
    box off;
    if(~isempty(options.legend))
        legend([p1 p2], options.legend, 'Box', 'off');
    end
    if ~options.plotDiff
        return;
    end
    
    ax(2) = subplot(2, 1, 2);
    
    if options.isMatched
        abDiff      = matA - matB;
        meanDiff = mean(abDiff, 2, 'omitnan');
        stdDiff = std(abDiff, 0, 2, 'omitnan');
        nDiff = size(abDiff, 2);
        ciDiff = ciLevel .* stdDiff ./ sqrt(nDiff);
        
        meanDiff = meanDiff';
        ciDiff = ciDiff';
        
        plot(x, meanDiff, 'k-', 'LineWidth', 1.5);
        hold on;
        plot([x(1) x(end)], [0 0], 'r--', 'LineWidth', 1);
        fill([x fliplr(x)],[meanDiff-ciDiff fliplr(meanDiff+ciDiff)], 'k', 'EdgeColor', [1 1 1], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    else
        [~, ~, stdpool] = pooledmeanstd(nA, meanA, stdA, nB, meanB, stdB);
        meanDiff      = meanA - meanB;
        ciDiff = ciLevel .* stdpool .* sqrt((1/nA) + (1/nB));
        
        plot(x, meanDiff, 'k-', 'LineWidth', 1.5);
        hold on;
        plot([x(1) x(end)], [0 0], 'r--', 'LineWidth', 1);
        fill([x fliplr(x)],[meanDiff-ciDiff fliplr(meanDiff+ciDiff)], 'k', 'EdgeColor', [1 1 1], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    end
    
    linkaxes(ax, 'xy');
    box off;
else
    plot(x, meanA, strcat(options.colorCode,'-'), 'LineWidth', 1.5);
    hold on;
    fill([x fliplr(x)],[meanA-ciA fliplr(meanA+ciA)], options.colorCode, 'EdgeColor', [1 1 1], 'FaceAlpha', 0.2, 'EdgeAlpha', 0);
    hold off;
    box off;
    ax = axis;
    axis([0 x(end) ax(3) ax(4)])
end
end

