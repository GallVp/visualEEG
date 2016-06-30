classdef operationSets < handle
    %OPERATIONSETS Container class for eegOperations class objects.
    %   Detailed explanation goes here
    
    % Copyright (c) <2016> <Usman Rashid>
    %
    % This program is free software; you can redistribute it and/or
    % modify it under the terms of the GNU General Public License as
    % published by the Free Software Foundation; either version 2 of the
    % License, or (at your option) any later version.  See the file
    % LICENSE included with this distribution for more information.
    
    properties (SetAccess = private)
        names               % A cell array containing names of the opertion Sets.
        oSets               % A cell array containing object handles of the eegClass.
        numOperationSets    % Total number of operation sets.
        dataEeg             % Handle of data set (eegData) attached to these operationSets.
        operationSetNum     % Serial number of current operation set.
        operationSetOptions % Options for the operation set. A row cell array.
    end
    
    methods
        function [obj] = operationSets(data)
            obj.numOperationSets = 1;
            obj.operationSetNum = 1;
            obj.dataEeg = data;
            obj.oSets{obj.operationSetNum} = eegOperations(obj.dataEeg);
            obj.names{obj.operationSetNum} = 'Set 1';
        end
    end
    
    methods (Access = public)
        
        function [name] = getName(obj)
            name = obj.names{obj.operationSetNum};
        end
        
        function [answer] = isempty(obj)
            answer = obj.numOperationSets == 0;
        end
        
        function [oSet] = getOperationSet(obj)
            oSet = obj.oSets{obj.operationSetNum};
        end
        
        function addOpearionSet(obj, name)
            obj.numOperationSets = obj.numOperationSets + 1;
            obj.operationSetNum = obj.numOperationSets;
            obj.oSets{obj.operationSetNum} = eegOperations(obj.dataEeg);
            obj.names{obj.operationSetNum} = name;
            obj.operationSetOptions{obj.operationSetNum, 1} = 1;
        end
        
        function rmOpearionSet(obj)
            if(obj.operationSetNum ~= 1)
                obj.oSets{obj.operationSetNum} = [];
                obj.names{obj.operationSetNum} = [];
                obj.numOperationSets = obj.numOperationSets - 1;
                obj.operationSetNum = obj.operationSetNum - 1;
            else
                ME = MException('operationSets:remove:defalutOpSet', 'Default operation set cannot be removed.');
                throw(ME)
            end
        end
        
        function [answer] = isApplied(obj)
            answer = obj.operationSetOptions{obj.operationSetNum, 1} == 1;
        end
        
        function setApplied(obj, apply)
            obj.operationSetOptions{obj.operationSetNum, 1} = apply;
        end
        
        function selectOperationSet(obj, operationSetNum)
            if(operationSetNum < 1 || operationSetNum > obj.numOperationSets)
                ME = MException('operationSets:select:noSuchOperationSet', 'No such operation set exists.');
                throw(ME)
            else
                obj.operationSetNum = operationSetNum;
            end
        end
    end
    
end

