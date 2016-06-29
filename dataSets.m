classdef dataSets < handle
    %DATSETS Container class for eegData class objects.
    %   Detailed explanation goes here
    
    
    % Copyright (c) <2016> <Usman Rashid>
    %
    % This program is free software; you can redistribute it and/or
    % modify it under the terms of the GNU General Public License as
    % published by the Free Software Foundation; either version 2 of the
    % License, or (at your option) any later version.  See the file
    % LICENSE included with this distribution for more information.


properties (SetAccess = private)
        names               % A cell array containing names of the data Sets.
        oSuperSets          % A cell array containing object handles of the operationSets class.
        numDataSets         % Total number of operation sets.
        dSets               % A cell array containing object handles of the eegData class.
        dataSetNum          % Serial number of current data set.
    end
    
    methods
        function [obj] = dataSets
            obj.numDataSets = 0;
            obj.dataSetNum = 0;
        end
    end
    
    methods (Access = public)
        
        function [name] = getName(obj)
            name = obj.names{obj.dataSetNum};
        end
        
        function [answer] = isempty(obj)
            answer = obj.numDataSets == 0;
        end
        
        function [oSS] = getOperationSuperSet(obj)
            oSS = obj.oSuperSets{obj.dataSetNum};
        end
        
        function addDataSet(obj)
            obj.dSets{obj.dataSetNum} = eegData;
            obj.numDataSets = obj.numDataSets + 1;
            obj.dataSetNum = obj.numDataSets;
            obj.oSuperSets{obj.dataSetNum} = operationSets(obj.dSets{obj.dataSetNum});
            
            % Getting dataset name
            str = obj.dSets{obj.dataSetNum}.folderName;
            expression = '\/';
            splitStr = regexp(str,expression,'split');
            obj.names{obj.dataSetNum} = splitStr(length(splitStr));
        end
        
        function rmDataSet(obj)
            obj.dSets(obj.dataSetNum) = [];
            obj.names(obj.dataSetNum) = [];
            obj.oSuperSets(obj.dataSetNum) = [];
            obj.numDataSets = obj.numDataSets - 1;
            switch(obj.numDataSets)
                case 0
                    obj.dataSetNum = 0;
                case 1
                    obj.dataSetNum = 1;
                otherwise
                    if(obj.dataSetNum == 1)
                        obj.dataSetNum = obj.dataSetNum + 1;
                    else
                        obj.dataSetNum = obj.dataSetNum - 1;
                    end
            end
        end
        
        function selectDataSet(obj, dataSetNum)
            if(dataSetNum < 1 || dataSetNum > obj.numDataSets)
                ME = MException('dataSets:select:noSuchDataSet', 'No such data set exists.');
                throw(ME)
            else
                obj.dataSetNum = dataSetNum;
            end
        end
    end
    
end

