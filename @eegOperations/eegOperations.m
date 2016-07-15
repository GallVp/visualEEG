classdef eegOperations < matlab.mixin.Copyable
%EEGOPERATIONS A class which can be connected to an eegData class and can
%perform different operations on the data.
%
% Constructors eegOperations(eegData) and eegOperations(eegData, dataSets)
% instantiate an object. If a dataSets object is not passed,
% inter-operation set and inter-data set operations can not be added.
%
% getProcData(apply) returns an object of sstData class containing the
% processed data. If apply is 1, processed data is returned. If apply is 0,
% unprocessed data is returned. Default value of apply is 1.
%
% addOperation shows a gui which can be used to add an operation.
%
% rmOperation(index) removes the operation at index in the list of
% operations.
%
% 
% Public properties: operations -- A read-only property which lists the
% added operations.


% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.  See the file LICENSE included with this
% distribution for more information.
    
    
    
    properties (Constant)
        ALL_OPERATIONS = {'Mean', 'Grand Mean', 'Detrend', 'Normalize', 'Filter', 'FFT', 'Spatial Laplacian',...
            'PCA', 'FAST ICA', 'Optimal SF', 'Threshold by Std.', 'Abs', 'Detect Peak', 'Shift with EMG Cue',...
            'Remove Common Mode', 'Group Epochs', 'Shift Cue', 'Combine Data', 'Resample', 'Delay', 'Gain', 'Detect EMG Cue',...
            'Two Segment SVM Train', 'Two Segment SVM Test', 'Two Segment SVM Validate'};
        COMBINE_OPTIONS = {'Across Channels'};
    end
    
    properties (SetAccess = private)
        operations  % Operations applied to data
    end
    
    properties (Access = private)
        arguments       % Arguments for each operation
        dataSet         % An object of class sstData. Unapplied data.
        procData        % Processed data. An object of sstData class.
        numApldOps      % Number of applied operations.
        dataChangeName  % Name of change in source data.
        availOps        % Operations available
        storedArgs      % A structure with stored volatile args.
                        % Volatile args are the one which are asked during
                        % application of operation
        dSets           % A reference to dataSets class
        dSet            % A reference to corresponding eegData class
    end
    
    methods(Access = protected)
        % Override copyElement method:
        function cpObj = copyElement(obj)
            % Make a shallow copy of all properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the procData, dataSet, listener objects
            cpObj.procData = copy(obj.procData);
            cpObj.dataSet = copy(obj.dataSet);
            addlistener(cpObj.dSet,'dataSelectionChanged',@cpObj.handleDataSelectionChange);
        end
    end
    methods (Access = public)
        
        function [obj] = eegOperations(data, dSets)
            obj.dataSet = data.getSstData;
            obj.dSet = data;
            if nargin < 2
                obj.dSets = [];
            else
                obj.dSets = dSets;
            end

            % Default properties
            obj.numApldOps = 0;
            obj.availOps = eegOperations.ALL_OPERATIONS;
            obj.procData = data.getSstData;
            addlistener(data,'dataSelectionChanged',@obj.handleDataSelectionChange);
            
            % Stored args. These arguments are asked for during
            % applyOperation function rather than askArgs function.
            obj.storedArgs.('sLCentre') = [];
            obj.storedArgs.('eignVect') = [];
            obj.storedArgs.('SVM_Model') = [];
        end
        function handleDataSelectionChange(obj, src, eventData)
            obj.dataChangeName = eventData.changeName;
            obj.numApldOps = 0;
            obj.procData = src.getSstData;
            obj.dataSet = src.getSstData;
            applyAllOperations(obj);
        end
        function explicitHandleDataSelectionChange(obj)
            obj.dataChangeName = 'EXPLICIT_CHANGE';
            obj.numApldOps = 0;
            obj.procData = obj.dSet.getSstData;
            obj.dataSet = obj.dSet.getSstData;
            applyAllOperations(obj);
        end
        function [returnData] = getProcData(obj, apply)
            if(nargin < 2)
                apply = 1;
            end
            if(apply)
                returnData = obj.procData;
            else
                returnData = obj.dataSet;
            end
        end
        function [success] = addOperation (obj)
            [s,~] = listdlg('PromptString','Select an operation:', 'SelectionMode','single', 'ListString', ...
                obj.availOps);
            if(isempty(s))
                success = 0;
            else
                
                opName = obj.availOps(s);
                
                index = strcmp(eegOperations.ALL_OPERATIONS, opName);
                indices = 1:length(eegOperations.ALL_OPERATIONS);
                index = indices(index);
                
                args = obj.askArgs(s);
                if(isempty(args))
                    success = 0;
                else
                    if(isempty(obj.operations))
                        obj.operations = eegOperations.ALL_OPERATIONS(index);
                        obj.arguments = {args};
                    else
                        obj.operations = [obj.operations, eegOperations.ALL_OPERATIONS(index)];
                        obj.arguments = [obj.arguments {args}];
                    end
                    success = 1;
                end
            end
            applyAllOperations(obj);
        end
        function rmOperation (obj, index)                   % Here index refers to index of operations.
            if nargin < 2
                index = length(obj.operations);
            end
            
            selection = 1:length(obj.operations);
            selection = selection ~= index;
            obj.operations = obj.operations(selection);
            obj.arguments = obj.arguments(selection);
            
            obj.procData = copy(obj.dataSet);
            obj.numApldOps = 0;
            applyAllOperations(obj);
        end
    end
    
    methods (Access = private) % Functions defined in separate files
        [returnArgs] = askArgs(obj, index)
        applyOperation(obj, operationName, args,  processingData, operationNum)
    end
    
    methods (Access = private)
        function applyAllOperations(obj)
            
            numOperations = length(obj.operations);
            for i=obj.numApldOps + 1 :numOperations
                try
                    obj.applyOperation(obj.operations{i}, obj.arguments{i}, obj.procData, i);
                catch ME
                    if(strcmp(ME.identifier, 'eegOperations:applyOperation:operationFailed'))
                        fprintf('%s failed. Reason: %s \nIt is being removed from the operation list.\n',obj. operations{i}, ME.message);
                        obj.rmOperation(i);
                    else
                        throw(ME)
                    end
                end
            end
            obj.numApldOps = length(obj.operations);
        end
    end
    methods (Access = public, Static)
        
        function [ P, nT ] = shapeProcessing( S )
            
            [m, n, o] = size(S);
            
            P = zeros(m*o, n);
            
            for i=1:o
                P((m*(i-1))+1:m*i, :) = S(:,:,i);
            end
            nT = o;
        end
        
        function [ S ] = shapeSst( P, nT )  
            [m, n] = size(P);
            rm = m/nT;
            S = zeros(rm, n, nT);
            for i=1:nT
                S(:, :, i) = P((rm*(i-1))+1:rm*i, :);
            end
        end
    end
end

