function [argFunc, opFunc] = askQuestion
%askQuestion Asks a yes no question using the text set by setQuestionText.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % No argument required.
        if(~isfield(opData, 'questionText'))
            h = errordlg(sprintf('Operation only applicable if questionText variable is set.'),...
                'askQuestion', 'modal');
            uiwait(h);
            returnArgs = {};
            return;
        else
            returnArgs = {'N.R.'};
        end
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % No argument required.
        % Add custom updateView function along with the previous updateView
        % In case there was no previous updateView, use the default
        % updateView. This is a very powerful technique to chain updateView
        % functions.
        oldUpdateView = opData.updateView;
        if(isempty(oldUpdateView))
            oldUpdateView = @defaultUpdateView;
        end
        function opDataOut = defaultUpdateView(axH, opData)
            opDataOut = opData;
            % Code directly copied from updateView function in visualEEG.m
            % Plot data
            dat = opData.channelStream;
            
            if(size(dat, 2) > 128)
                disp('Warning: Only plotting first 128 channels');
                dat = dat(:, 1:128);
            end
            absc = opData.abscissa;
            
            plot(axH, absc, dat(:,:, opData.epochNum));
            % Set axis labels
            xlabel('Time (s)');
            ylabel('Amplitude');
        end
        function opDataOut = oldAndNewUpdateView(axH, passedData)
            opDataOut = oldUpdateView(axH, passedData);
            opDataOut = updateView(axH, opDataOut);
        end
        opDataOut.updateView = @oldAndNewUpdateView;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
        if(~isfield(opData, 'questionText'))
            questionText = {'?'};
        else
            questionText = opData.questionText;
        end
        if(~isfield(opData, 'questionAnswer'))
            answer = questdlg(questionText, 'askQuestion', 'Yes', 'No', 'No answer', 'No answer');
            opDataOut.questionAnswer = answer;
        end
    end
end