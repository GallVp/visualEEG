function [returnArgs] = askArgs(operationName)

ALL_OPERATIONS = {'Detrend', 'Normalize', 'Abs', 'Remove Common Mode', 'Resample',...
    'Filter', 'FFT', 'Spatial Filter',...
    'Create Epochs',...
    'Channel Mean', 'Epoch Mean'};

switch operationName
    
    
    case ALL_OPERATIONS{1} % Detrend
        % args{1} should be 'linear' or 'constant'.
        options = {'constant', 'linear'};
        [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','single',...
            'ListString', options, 'ListSize', [160 75]);
        returnArgs = options(s);
        
        
    case ALL_OPERATIONS{2} % Normalize
        % No argument required.
        returnArgs = {'N.R.'};
        
    case ALL_OPERATIONS{3} % Abs
        % No argument required.
        returnArgs = {'N.R.'};
        
    case ALL_OPERATIONS{4} % Remove Common Mode
        % No argument required.
        returnArgs = {'N.R.'};
        
    case ALL_OPERATIONS{5} % Resample
        % args{1} should be p and args{2} should be q. p/q is
        % the sampling ratio.
        prompt = {'p:', 'q:'};
        dlg_title = 'Ratio p/q';
        num_lines = 1;
        defaultans = {'1', '2'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        p = str2double(answer{1});
        q = str2double(answer{2});
        if(isempty(p) || isempty(q))
            returnArgs = {};
        else
            if(p <= 0 || q <=0 || isnan(p) || isnan(q))
                returnArgs = {};
            else
                returnArgs = {p, q};
            end
        end
    case ALL_OPERATIONS{8} % Spatial Filter
        % args{1} should be channel weights
        prompt = {'Channel weights:'};
        dlg_title = 'Spatial filter';
        num_lines = 1;
        defaultans = {'[]'};
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        if(isempty(answer))
            returnArgs = {};
            return;
        end
        cWeights = str2num(answer{1});
        if(isempty(cWeights))
            returnArgs = {};
        else
            returnArgs = {cWeights};
        end
        
        
        % args{1} should be p and args{2} should be q. p/q is
        % the sampling ratio.
        %     case eegOperations.ALL_OPERATIONS{1} % Mean
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{2} % Grand Mean
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{3} % Detrend
        %         options = {'constant', 'linear'};
        %         [s,~] = listdlg('PromptString','Select type:', 'SelectionMode','single',...
        %             'ListString', options, 'ListSize', [160 25]);
        %         returnArgs = options(s);
        %         % args{1} should be 'linear' or 'constant'.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{4} % Normalize
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{5} % Filter
        %         dataOut = selectFilterDlg;
        %         if(isempty(dataOut))
        %             returnArgs = {};
        %         else
        %             returnArgs = {dataOut.selectedFilter};
        %             % args{1} should be a filter object obtained from designfilter.
        %         end
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{6} % FFT
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{7} % Spatial Laplacian
        %         returnArgs = {'N.R.'};
        %         obj.storedArgs.('sLCentre') = [];
        %         % storedArgs is cleared here to ensure that when
        %         % this operation is added after removal, it asks for
        %         % argument during operation execution.
        %         % No argument required. Which in fact is delayed to
        %         % applyOpertion.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{8} % PCA
        %         returnArgs = {'N.R.'};
        %         obj.storedArgs.('eignVect') = [];
        %         % storedArgs is cleared here to ensure that when
        %         % this operation is added after removal, it asks for
        %         % argument during operation execution.
        %         % No argument required. Which in fact is delayed to
        %         % applyOpertion.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{9} % FAST ICA
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{10} % Optimal SF
        %         prompt = {'Enter signal time [Si Sf]:','Enter noise time [Ni Nf] (empty = ~[Si Sf]):', 'Per epoch?(1,0):'};
        %         dlg_title = 'Input';
        %         num_lines = 1;
        %         defaultans = {'[]','[]', '1'};
        %         answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        %         if(isempty(answer))
        %             returnArgs = {};
        %         else
        %             signalInterval = str2num(answer{1}); %% Don't change it to str2double as it is an array
        %             noiseInterval = str2num(answer{2});
        %             if(length(signalInterval) ~= 2 || signalInterval(2) <= signalInterval(1))
        %                 errordlg('The format of intervals is invalid.', 'Interval Error', 'modal');
        %                 returnArgs = {};
        %             else
        %
        %                 returnArgs = {signalInterval; noiseInterval; str2double(answer{3})};
        %             end
        %         end
        %         % args{1} should be a 1 by 2 vector containing signal
        %         % time. args{2} should be a 1 by 2 vector containing
        %         % noise time. arg{3} should be 1/0 for per epoch
        %         % processing
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{11} % Threshold by Std.
        %         prompt={'Enter number of stds:'};
        %         name = 'Std number';
        %         defaultans = {'1'};
        %         answer = inputdlg(prompt,name,[1 40],defaultans);
        %         answer = str2double(answer);
        %         if(isempty(answer))
        %             returnArgs = {};
        %         else
        %             if(isnan(answer) || answer <= 0)
        %                 returnArgs = {};
        %             else
        %                 returnArgs = {answer};
        %             end
        %         end
        %         % args{1} should be number of stds to use.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{12} % Abs
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{13} % Detect Peak
        %         prompt={'Amplitude >=:', 'Nth peak (0 for all):'};
        %         name = 'Detect peak';
        %         defaultans = {'1', '1'};
        %         answer = inputdlg(prompt,name,[1 40],defaultans);
        %         answer = str2double(answer);
        %         answer(2) = round(answer(2));
        %         if(isempty(answer(1)) || isempty(answer(2)))
        %             returnArgs = {};
        %         else
        %             if(isnan(answer(1))  || answer(2) < 0 || isnan(answer(2)))
        %                 returnArgs = {};
        %             else
        %                 returnArgs = {answer(1), answer(2)};
        %             end
        %         end
        %         % args{1} should be the threshold amplitude. args{2}
        %         % should be the peak number.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{14} % Shift with EMG Cue
        %         if(isempty(obj.dSets))
        %             uiwait(errordlg('No datasets attached.','Combine Data', 'modal'));
        %
        %             returnArgs = {};
        %         else
        %             dataIn.('dSets') = obj.dSets;
        %
        %             dataIn.('availableCombinations') = {'Shift with EMG cues'};
        %             dataOut = combineDataDlg(dataIn);
        %             if(isempty(dataOut))
        %                 returnArgs = {};
        %             else
        %                 if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
        %                         == obj.dSets.getOperationSuperSet.operationSetNum)
        %                     uiwait(errordlg('Combining data from the same operation set is not allowed.','Shift Data', 'modal'));
        %                     returnArgs = {};
        %                 else
        %                     dSetNum = dataOut.('dataSetNum');
        %                     opSetNum = dataOut.('operationSetNum');
        %                     obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
        %                     combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
        %                     if(strcmp(combineData.dataType, sstData.DATA_TYPE_TIME_EVENT))
        %                         returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
        %                             dataOut.('operationSetNum')};
        %                     else
        %                         uiwait(errordlg('Source data type is not appropriate.','Shift Data', 'modal'));
        %                         returnArgs = {};
        %                     end
        %                 end
        %             end
        %         end
        %         % args{1} should be combination Number (always 1). args{2} should be the data set
        %         % number. args{3} should be operation set number.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{15} % Remove Common Mode
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{16} % Group Epochs
        %         prompt = {'Epoch groups:', 'Group number to select:'};
        %         dlg_title = 'Select epochs';
        %         num_lines = 1;
        %         defaultans = {'2', '1'};
        %         answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        %         numGroups = str2double(answer{1});
        %         groupNum = str2double(answer{2});
        %         if(isempty(numGroups) || isempty(groupNum))
        %             returnArgs = {};
        %         else
        %             if(numGroups <= 0 || groupNum > numGroups || groupNum <=0 || isnan(numGroups) || isnan(groupNum))
        %                 returnArgs = {};
        %             else
        %                 returnArgs = {numGroups, groupNum};
        %             end
        %         end
        %         % args{1} should be total number of groups, while
        %         % args{2} should be the selected group's number.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{17} % Shift Cue
        %         prompt={'Enter delay for each cue:',};
        %         name = 'Shift Cue';
        %         defaultans = {'1'};
        %         answer = inputdlg(prompt,name,[1 40],defaultans);
        %         if(isempty(answer))
        %             returnArgs = {};
        %         else
        %             answer = str2num(answer{:});
        %             if(isnan(answer))
        %                 returnArgs = {};
        %             else
        %                 returnArgs = {answer};
        %             end
        %         end
        %         % args{1} should be a vector of delays. Number of
        %         % elements will determine number of cues.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{18} % Combine Data
        %         if(isempty(obj.dSets))
        %             uiwait(errordlg('No datasets attached.','Combine Data', 'modal'));
        %
        %             returnArgs = {};
        %         else
        %             dataIn.('dSets') = obj.dSets;
        %
        %             dataIn.('availableCombinations') = obj.COMBINE_OPTIONS;
        %             dataOut = combineDataDlg(dataIn);
        %             if(isempty(dataOut))
        %                 returnArgs = {};
        %             else
        %                 if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
        %                         == obj.dSets.getOperationSuperSet.operationSetNum)
        %                     uiwait(errordlg('Combining data from the same operation set is not allowed.','Combine Data', 'modal'));
        %                     returnArgs = {};
        %                 else
        %                     returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
        %                         dataOut.('operationSetNum')};
        %                 end
        %             end
        %         end
        %         % args{1} should be combination Number refering to
        %         % COMBINE_OPTIONS. args{2} should be the data set
        %         % number. args{3} should be operation set number.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{19} % Resample
        %         prompt = {'p:', 'q:'};
        %         dlg_title = 'Ratio p/q';
        %         num_lines = 1;
        %         defaultans = {'1', '2'};
        %         answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        %         p = str2double(answer{1});
        %         q = str2double(answer{2});
        %         if(isempty(p) || isempty(q))
        %             returnArgs = {};
        %         else
        %             if(p <= 0 || q <=0 || isnan(p) || isnan(q))
        %                 returnArgs = {};
        %             else
        %                 returnArgs = {p, q};
        %             end
        %         end
        %         % args{1} should be p and args{2} should be q. p/q is
        %         % the sampling ratio.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{20} % Delay
        %         prompt={'Delay time (sec.):'};
        %         name = 'Delay Signal';
        %         defaultans = {'1'};
        %         answer = inputdlg(prompt,name,[1 40],defaultans);
        %         answer = str2double(answer);
        %         if(isempty(answer))
        %             returnArgs = {};
        %         else
        %             if(isnan(answer))
        %                 returnArgs = {};
        %             else
        %                 returnArgs = {answer};
        %             end
        %         end
        %         % args{1} should be delay time in seconds
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{21} % Gain
        %         prompt={'Enter gain:'};
        %         name = 'Signal Gain';
        %         defaultans = {'1'};
        %         answer = inputdlg(prompt,name,[1 40],defaultans);
        %         answer = str2double(answer);
        %         if(isempty(answer))
        %             returnArgs = {};
        %         else
        %             if(isnan(answer))
        %                 returnArgs = {};
        %             else
        %                 returnArgs = {answer};
        %             end
        %         end
        %         % args{1} should be gain
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{22} % Detect EMG Cue
        %         returnArgs = {'N.R.'};
        %         % No argument required.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{23} % Two Segment SVM Train
        %         interval = obj.procData.interval;
        %         prompt = {'Segment 1 start:', 'Segment 1 end:','Segment 2 start:','Segment 2 end:',...
        %             'Regulization C:','Passes:', sprintf('Data permutation\nRandom=0/Sequential=1/Alternate=2')};
        %         dlg_title = 'SVM Train';
        %         num_lines = 1;
        %         defaultans = {num2str(interval(1)), num2str(interval(2)/2), num2str(interval(2)/2), num2str(interval(2)), '100', '20', '0'};
        %         answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        %         s1s = str2double(answer(1)); % Segment 1 start
        %         s1e = str2double(answer(2)); % Segment 1 end
        %         s2s = str2double(answer(3)); % segment 2 start
        %         s2e = str2double(answer(4)); % Segment 2 end
        %         c = str2double(answer(5)); % Regulization C
        %         p = round(str2double(answer(6))); % Number of passes
        %         permu = str2double(answer(7)); % Permutaions
        %         if(isempty(s1s) || isempty(s1e) || isempty(s2s) || isempty(s2e) || isempty(c) || isempty(p) || isempty(permu))
        %             returnArgs = {};
        %         else
        %             if(isnan(s1s) || isnan(s1e) || isnan(s2s) || isnan(s2e) || isnan(c) || isnan(p) || isnan(permu))
        %                 returnArgs = {};
        %             else
        %                 if(s1s < interval(1) || s2e > interval(2) || c < 0 || p <= 0 ||...
        %                         permu < 0 || permu > 2 || s1s >= s1e || s2s >= s2e)
        %                     returnArgs = {};
        %                 else
        %                     if(abs(s1s - s1e) ~= abs(s2s - s2e))
        %                         uiwait(errordlg('Both intervals should be equal.','SVM Train', 'modal'));
        %                         returnArgs = {};
        %                     else
        %                         returnArgs = {s1s, s1e, s2s, s2e, c, p, permu};
        %                     end
        %                 end
        %             end
        %         end
        %         obj.storedArgs.('SVM_Model') = [];
        %         % returnArgs = {s1s, s1e, s2s, s2e, c, p, permu};
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{24} % Two Segment SVM Test
        %         if(isempty(obj.dSets))
        %             uiwait(errordlg('No datasets attached.','SVM Test', 'modal'));
        %
        %             returnArgs = {};
        %         else
        %             dataIn.('dSets') = obj.dSets;
        %
        %             dataIn.('availableCombinations') = {'Load SVM Model'};
        %             dataOut = combineDataDlg(dataIn);
        %             if(isempty(dataOut))
        %                 returnArgs = {};
        %             else
        %                 if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
        %                         == obj.dSets.getOperationSuperSet.operationSetNum)
        %                     uiwait(errordlg('Combining data from the same operation set is not allowed.','SVM Test', 'modal'));
        %                     returnArgs = {};
        %                 else
        %                     dSetNum = dataOut.('dataSetNum');
        %                     opSetNum = dataOut.('operationSetNum');
        %                     obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
        %                     combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
        %                     if(strcmp(combineData.dataType, sstData.DATA_TYPE_PREDICTION))
        %                         returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
        %                             dataOut.('operationSetNum')};
        %                     else
        %                         uiwait(errordlg('Source data type is not appropriate.','SVM Test', 'modal'));
        %                         returnArgs = {};
        %                     end
        %                 end
        %             end
        %         end
        %         % args{1} should be combination Number refering to
        %         % COMBINE_OPTIONS. args{2} should be the data set
        %         % number. args{3} should be operation set number.
        %
        %
        %
        %     case eegOperations.ALL_OPERATIONS{25} % Two Segment SVM Validate
        %         if(isempty(obj.dSets))
        %             uiwait(errordlg('No datasets attached.','SVM Validate', 'modal'));
        %
        %             returnArgs = {};
        %         else
        %             dataIn.('dSets') = obj.dSets;
        %
        %             dataIn.('availableCombinations') = {'Load SVM Model'};
        %             dataOut = combineDataDlg(dataIn);
        %             if(isempty(dataOut))
        %                 returnArgs = {};
        %             else
        %                 if(dataOut.('dataSetNum') == obj.dSets.dataSetNum && dataOut.('operationSetNum')...
        %                         == obj.dSets.getOperationSuperSet.operationSetNum)
        %                     uiwait(errordlg('Combining data from the same operation set is not allowed.','SVM Validate', 'modal'));
        %                     returnArgs = {};
        %                 else
        %                     dSetNum = dataOut.('dataSetNum');
        %                     opSetNum = dataOut.('operationSetNum');
        %                     obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).explicitHandleDataSelectionChange;
        %                     combineData = obj.dSets.getOperationSuperSet(dSetNum).getOperationSet(opSetNum).getProcData;
        %                     if(strcmp(combineData.dataType, sstData.DATA_TYPE_PREDICTION))
        %                         prompt = {'C initial:', 'Step:','C final:'};
        %                         dlg_title = 'SVM Validate';
        %                         num_lines = 1;
        %                         defaultans = {'1', '10', '100'};
        %                         answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
        %                         cInit = str2double(answer(1));
        %                         cStep = str2double(answer(2));
        %                         cFinal = str2double(answer(3));
        %                         if(isempty(cInit) || isempty(cStep) || isempty(cFinal))
        %                             returnArgs = {};
        %                         else
        %                             if(isnan(cInit) || isnan(cStep) || isnan(cFinal))
        %                                 returnArgs = {};
        %                             else
        %                                 if(cInit >= s2s || cStep >= cFinal)
        %                                     returnArgs = {};
        %                                 else
        %                                     returnArgs = {dataOut.('combinationNum'), dataOut.('dataSetNum'),...
        %                                         dataOut.('operationSetNum'), cInit, cStep, cFinal};
        %                                 end
        %                             end
        %                         end
        %                     else
        %                         uiwait(errordlg('Source data type is not appropriate.','SVM Validate', 'modal'));
        %                         returnArgs = {};
        %                     end
        %                 end
        %             end
        %         end
        %         % returnArgs = {Combination Number, Dataset Number,
        %         % Operationset Number, cInit, cStep, cFinal}. Where C
        %         % is regularization parameter
        %
        %
        
    otherwise
        returnArgs = {};
end
end