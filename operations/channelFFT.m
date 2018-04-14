function [argFunc, opFunc] = channelFFT
%channelFFT Performs fft for each channel
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
        if(opData.numEpochs > 1)
            processedData = zeros(size(opData.channelStream));
            for i=1:opData.numEpochs
                [x, f] = computeFFT(opData.channelStream(:, :, i), opData.fs);
                processedData(1:length(f), :, i) = x;
            end
            processedData = processedData(1:length(f), :, :);
        else
            [processedData, f] = computeFFT(opData.channelStream, opData.fs);
        end
        opDataOut.frequencyStream = processedData;
        opDataOut.fftFreq = f;
        
        % Add custom updateView function
        opDataOut.updateView = @updateView;
    end
%% Update the view
    function updateView(axH, opData)
        plot(axH, opData.fftFreq, opData.frequencyStream(:,:, opData.epochNum));
        xlabel(axH, 'Frequency (Hz)');
        ylabel(axH, 'Amplitude');
    end
end