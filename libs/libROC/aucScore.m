function score = aucScore(tpr, fpr)
%aucScore Find AUC score from tpr and fpr column vectors.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.
tpr = tpr ./100;
fpr = fpr ./ 100;
xDist = diff(fpr);
score = 0;
for i=1:length(xDist)
    score = score + (tpr(i) + tpr(i+1))/2.*xDist(i);
end
end