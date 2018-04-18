function [argFunc, opFunc] = setQuestionText
%setQuestionText Adds text for a yes no question to be used by askQuestion
%   function.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % args{1} should be questionText
        prompt = {'Questio text:'};
        dlg_title = 'Set Question Text';
        num_lines = 1;
        defaultans = {'?'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        questionText = answer{1};
        if(isempty(questionText))
            returnArgs = {};
        else
            returnArgs = {questionText};
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % args{1} should be questionText
        questionText = args{1};
        opDataOut.questionText = questionText;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end