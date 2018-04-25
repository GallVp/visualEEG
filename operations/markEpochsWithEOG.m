function [argFunc, opFunc] = markEpochsWithEOG
%removeEpochsWithEOG Removes epochs using EOG channel. The filter range is
%   set at [0.05 40] Hz and eyeblink threshold is set at 75 uV.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        
        % Check to make sure data has epochs
        if(isempty(opData.eogChannel) || ~isfield(opData, 'events'))
            h = errordlg(sprintf('Operation only applicable to\ndata with eogChannel and epochs.'),...
                'removeEpochsWithFp1', 'modal');
            uiwait(h);
            returnArgs = {};
            return;
        end
        
        % No argument required.
        returnArgs = {'N.R.'};
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % No argument required.
        EOG_LOW_FREQ        = 0.05;
        EOG_HIGH_FREQ       = 5;
        EYE_BLINK_THRESH    = 75;
        processedEOG        = filterStream(opData.eogChannel, opData.fs, 2, EOG_HIGH_FREQ, EOG_LOW_FREQ);
        processedEOG        = epochData(processedEOG, opData.events, opData.epochWindow(1), opData.epochWindow(2));
        epochsWithEyeBlink = (max(processedEOG) - min(processedEOG)) >= EYE_BLINK_THRESH;
 
        opDataOut.epochExcludeStatus        = epochsWithEyeBlink;
        opDataOut.epochsWithEyeBlink        = epochsWithEyeBlink;
        % Remove custom updateView function
        opDataOut.updateView = [];
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
    end
end