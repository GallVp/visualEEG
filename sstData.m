classdef sstData < matlab.mixin.Copyable
    %SSTDATA A class representing sstData
    % The properties represent information relative to actual data.
    
    properties (SetAccess = private)
        selectedData        % Current selection of data
        dataSize            % Size of sstData
        subjectNum          % Current selected subject
        sessionNum          % Current selected session
        dataRate            % Data sample rate
        channelNums         % Nums of currently selected channels
        channelNames        % Names of currently selected channels
        interval            % Interval of selected data
        epochNums           % Sr. Nos of epochs
        currentEpoch        % Currently selected epoch
    end
    
    methods
        function [epoch] = getEpoch(obj)
            epoch = obj.dataSst(:,:,obj.currentEpoch);
        end
        function [answer] = isempty(obj)
            answer = isempty(obj.dataSst);
        end
        function [answer] = isLastEpoch(obj)
            answer = obj.currentEpoch == obj.dataSize(3);
        end
        function [answer] = isFirstEpoch(obj)
            answer = obj.currentEpoch == 1;
        end
        function [epochNum] = absoluteEpochNum(obj)
            epochNum = obj.epochNums(obj.currentEpoch);
        end
        function [obj] = nextEpoch(obj)
            if(obj.isLastEpoch)
                ME = MException('sstData:lastEpoch', 'Current epoch is the last epoch.');
                throw(ME)
            else
                obj.currentEpoch = obj.currentEpoch + 1;
            end
        end
        function [obj] = previousEpoch(obj)
            if(obj.isFirstEpoch)
                ME = MException('sstData:firstEpoch', 'Current epoch is the first epoch.');
                throw(ME)
            else
                obj.currentEpoch = obj.currentEpoch - 1;
            end
        end
    end
end

