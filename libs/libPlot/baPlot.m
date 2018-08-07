function [bias, LOA, CR] = baPlot(dataVectA, dataVectB, labels, units)
%baPlot

if nargin < 3
    labels = {inputname(1), inputname(2)};
    units = 'units';
end

% Do calculations
meanVect    = (dataVectB + dataVectA) / 2;
diffVect    = dataVectB - dataVectA;

bias        = mean(diffVect, 'omitnan');
LOA          = bias + 1.96 .* [-std(diffVect, 'omitnan') std(diffVect, 'omitnan')];
CR          = 1.96 .* std(diffVect, 'omitnan');

if nargout == 0
    % Do plotting
    plot(meanVect, diffVect, 'rs', 'MarkerSize', 10);
    hold on;
    axInfo = axis;
    plot([axInfo(1) axInfo(2)], [bias bias], 'k-.');
    plot([axInfo(1) axInfo(2)], [LOA(1) LOA(1)], 'k--');
    plot([axInfo(1) axInfo(2)], [LOA(2) LOA(2)], 'k--');
    axis([axInfo(1) axInfo(2) axInfo(3) + LOA(1) axInfo(4) + LOA(2)]);
    axInfo = axis;
    
    % Print stats
    [~, pVal] = ttest(diffVect);
    text(axInfo(2), bias, sprintf('Bias: %0.3f\np: %0.3f\nCR: %0.3f', bias, pVal, CR))
    text(axInfo(2), LOA(1), sprintf('%0.3f', LOA(1)))
    text(axInfo(2), LOA(2), sprintf('%0.3f', LOA(2)))
    hold off;
    
    
    % Print labels
    if(isempty(labels))
        xlabel('Mean');
        ylabel('Difference');
    else
        xlabel(sprintf('Mean of %s and %s (%s)', labels{2}, labels{1}, units));
        ylabel(sprintf('%s - %s (%s)', labels{2}, labels{1}, units));
    end
    box off;
end
end

