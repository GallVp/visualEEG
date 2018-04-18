function [argFunc, opFunc] = channelPSD
%channelPSD Performs and plots the power spectral density for each channel.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

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
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                [x, f] = computePSD(opData.channelStream(:, :, i), opData.fs);
                processedData(1:length(f), :, i) = x;
            end
            processedData = processedData(1:length(f), :, :);
        else
            [processedData, f] = computePSD(opData.channelStream, opData.fs);
        end
        opDataOut.frequencyStream = processedData;
        opDataOut.fftFreq = f;
        
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function opDataOut = updateView(axH, opData)
        opDataOut = opData;
        plot(axH, opData.fftFreq, opData.frequencyStream(:,:, opData.epochNum));
        xlabel(axH, 'Frequency (Hz)');
        ylabel(axH, 'Power (dB)');
        grid on;
    end
end