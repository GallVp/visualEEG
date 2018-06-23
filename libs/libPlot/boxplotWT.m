function boxplotWT(boxData, groupVector, LTitles, XTitles, placeXTitlesAt, isLatex)
%boxplotWT Box plot with titles and colors for different groups.
%   boxData is a matrix with rows corresponding to values and columns
%   corresponding to groups. groupVector contains group number against each
%   column. length(Ltitles) assumed to be equal to number of groups.
%   length(XTitles) is assumed t be equal to numColumns / numGroups.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

if nargin < 6
    isLatex = 0;
end

[~, numColumns] = size(boxData);
numGroups = length(unique(groupVector));
if(length(LTitles) ~= numGroups || length(XTitles) ~= numColumns/numGroups)
    error('Number of titles should be equal to number of groups.');
end

boxplot(boxData);
set(findobj(gca,'type','line'),'linew',3);
set(findobj(gca,'type','line'),'MarkerSize',10);
h = findobj(gca,'Tag','Box');
h = h(end:-1:1);
m = findobj(gca,'Tag','Median');
o = findobj(gca,'Tag', 'Outliers');

matlabColors = get(gca,'colororder');
matlabColors = [matlabColors(1, :); matlabColors(3:end, :)];
medianColor = [1 0 0];
set(m, 'Color', medianColor);
set(o, 'MarkerEdgeColor', medianColor);

for j = 1:length(h)
    set(h(j), 'Color', matlabColors(groupVector(j), :)); % reordered to match
end
legend(h, LTitles, 'Location', 'NorthWest', 'EdgeColor', [1 1 1]);
if isLatex ~= 0
    set(gca,'TickLabelInterpreter','latex');
end
set(gca,'TickLength',[0 0])
set(gca, 'XTick', placeXTitlesAt);
xticklabels(gca, XTitles);
set(gca, 'FontSize', 12);
set(gcf, 'Color', [1 1 1]);
box off;
end