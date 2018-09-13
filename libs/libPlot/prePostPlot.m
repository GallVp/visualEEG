function prePostPlot(preData, postData)
%prePostPlot Create a pre-post plot
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

line([1:length(preData);1:length(preData)], [preData postData]', 'Color', [0 0 0], 'LineWidth', 2)
hold on;
preM    = plot(preData, 'ko', 'MarkerSize', 10);
postM   = plot(postData, 'r+', 'MarkerSize', 10, 'LineWidth', 3);

xlabel('id');
ylabel('Amplitude');
legend([preM postM], {'Pre', 'Post'}, 'Box', 'off');
box off;

axInfo = axis;
axis([axInfo(1) axInfo(2)+1 axInfo(3) axInfo(4)])
end

