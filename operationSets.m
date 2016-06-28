classdef operationSets < handle
    %OPERATIONSETS Container class for eegOperations class objects.
    %   Detailed explanation goes here
    
    properties (Access = private)
        names               % A cell array containing names of the opertion Sets.
        oSets               % A cell array containing object handles of the eegClass.
        operationSetNum     % Serial number of current operation set.
        numOperationSets    % Total number of operation sets.
        dataSet             % Handle of data set (eegData) attached to these operationSets.
    end
    
    methods
        function [obj] = operationSets(data)
            obj.numOperationSets = 0;
            obj.operationSetNum = 0;
            obj.dataSet = data;
        end
    end
    
    methods (Access = public)
        
        function [name] = getName(obj)
            name = obj.names{obj.operationSetNum};
        end
        
        function [answer] = isempty(obj)
            answer = ~(obj.numOperationSets == 0);
        end
        
        function [oSet] = getOperationSet(obj)
            oSet = obj.oSets{obj.operationSetNum};
        end
        
        function addOpearionSet(obj, name)
            obj.numOperationSets = obj.numOperationSets + 1;
            obj.operationSetNum = obj.numOperationSets;
            obj.oSets(obj.operationSetNum) = {eegOperations(obj.dataSet)};
            obj.names(obj.operationSetNum) = {name};
        end
        
        function rmOpearionSet(obj)
            obj.oSets(obj.operationSetNum) = [];
            obj.names(obj.operationSetNum) = [];
        end
    end
    
end

