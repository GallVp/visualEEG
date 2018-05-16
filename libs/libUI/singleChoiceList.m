function [ choiceMade ] = singleChoiceList(dlgTitle, choises)
%singleChoiceList Presents a dialog with a list.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for 
%   license information.

[s, v] = listdlg('PromptString', dlgTitle,...
                'SelectionMode', 'single',...
                'ListString', choises,...
                'ListSize', [250 120]);
if (v == 0)
    choiceMade = [];
else
    choiceMade = choises{s};
end
end

