function [argFunc, opFunc] = bpFeat
%bpFeat Finds the features in the bereitschaftspotential.
%
% Copyright (c) <2016> <Usman Rashid>
% Licensed under the MIT License. See License.txt in the project root for
% license information.

argFunc     = @askArgs;
opFunc      = @applyOperation;

%% Ask for arguments
    function returnArgs = askArgs(opData)
        % No argument required.
        returnArgs = {'N.R.'};
    end
%% Apply the operation
    function opDataOut = applyOperation(opData, args)
        opDataOut = opData;
        % No argument required.
        PN_WIN          = [-0.5 0.5];
        PN_WIN_LOGICAL  = opData.abscissa >= PN_WIN(1) & opData.abscissa <= PN_WIN(2);
        BP_IS_AT        = -2; %In seconds. Negative means before.
        bpIndex         = find(abs(opData.abscissa - BP_IS_AT) <= 1/opData.fs, 1);
        BP2_IS_AT       = -0.5; %In seconds. Negative means before.
        bp2Index        = find(abs(opData.abscissa - BP2_IS_AT) <= 1/opData.fs, 1);
        
        if(opData.numEpochs > 1)
            sz              = size(opData.channelStream);
            pnValue         = zeros(1, sz(2), sz(3));
            pnTime          = zeros(1, sz(2), sz(3));
            bp2Value        = zeros(1, sz(2), sz(3));   % If data is epoched, it is calculated otherwise []
            bpValue         = zeros(1, sz(2), sz(3));   % If data is epoched, it is calculated otherwise []
            for i=1:opData.numEpochs
                pnValue(:, :, i) = min(opData.channelStream(PN_WIN_LOGICAL, :, i));
                for j=1:opData.numChannels
                    % Calculated with respect to current epoch indices
                    pnTime(:, j, i) = opData.abscissa(find(opData.channelStream(:, j, i) == pnValue(:, j, i), 1));
                end
                if(~isempty(bpIndex))
                    bpValue(:, :, i) = opData.channelStream(bpIndex, :, i);
                else
                    bpValue(:, :, i) = [];
                end
                if(~isempty(bp2Index))
                    bp2Value(:, :, i) = opData.channelStream(bp2Index, :, i);
                else
                    bp2Value(:, :, i) = [];
                end
            end
        else
            pnValue = min(opData.channelStream(PN_WIN_LOGICAL, :, :));
            for j=1:opData.numChannels
                % Calculated with respect to current epoch indices
                pnTime(:, j) = opData.abscissa(find(opData.channelStream(:, j) == pnValue(:, j), 1));
            end
            if(~isempty(bpIndex))
                bpValue = opData.channelStream(bpIndex, :);
            else
                bpValue = [];
            end
            if(~isempty(bp2Index))
                bp2Value = opData.channelStream(bp2Index, :);
            else
                bp2Value = [];
            end
        end
        opDataOut.pnValue    = pnValue;
        opDataOut.pnTime     = pnTime;
        opDataOut.bpValue    = bpValue;
        opDataOut.bp2Value   = bp2Value;
        
        opDataOut.BP_IS_AT  = BP_IS_AT;
        opDataOut.BP2_IS_AT = BP2_IS_AT;
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function updateView(axH, opData)
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
        
        % Plot pn point
        hold on;
        plot(axH, opData.pnTime(:,:, opData.epochNum), opData.pnValue(:,:, opData.epochNum), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
        for jthChannel=1:opData.numChannels
            text(axH, opData.pnTime(:, jthChannel, opData.epochNum), opData.pnValue(:, jthChannel, opData.epochNum), sprintf(' --> MP(%g, %g)',...
                opData.pnTime(:, jthChannel, opData.epochNum), opData.pnValue(:, jthChannel, opData.epochNum)), 'FontSize', 12);
        end
        
        % Plot BP point
        if(~isempty(opData.bpValue))
            plot(axH, opData.BP_IS_AT, opData.bpValue(:,:, opData.epochNum), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
        end
        for jthChannel=1:opData.numChannels
            text(axH, opData.BP_IS_AT, opData.bpValue(:, jthChannel, opData.epochNum), sprintf(' --> BP1(%g, %g)',...
                opData.BP_IS_AT, opData.bpValue(:, jthChannel, opData.epochNum)), 'FontSize', 12);
        end
        
        % Plot BP2 point
        if(~isempty(opData.bp2Value))
            plot(axH, opData.BP2_IS_AT, opData.bp2Value(:,:, opData.epochNum), 'r.', 'LineWidth', 2, 'MarkerSize', 15);
        end
        for jthChannel=1:opData.numChannels
            text(axH, opData.BP2_IS_AT, opData.bp2Value(:, jthChannel, opData.epochNum), sprintf(' --> BP2(%g, %g)',...
                opData.BP2_IS_AT, opData.bp2Value(:, jthChannel, opData.epochNum)), 'FontSize', 12);
        end
        hold off;
    end
end