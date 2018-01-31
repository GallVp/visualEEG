function varargout = visualEEG(varargin)
% VISUALEEG MATLAB code for visualEEG.fig
%      VISUALEEG, by itself, creates a new VISUALEEG or raises the existing
%      singleton*.
%
%      H = VISUALEEG returns the handle to a new VISUALEEG or the handle to
%      the existing singleton*.
%
%      VISUALEEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALEEG.M with the given input arguments.
%
%      VISUALEEG('Property','Value',...) creates a new VISUALEEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visualEEG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visualEEG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualEEG


% Last Modified by GUIDE v2.5 30-Jan-2018 17:38:17

% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% LICENSE included with this distribution for more information.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @visualEEG_OpeningFcn, ...
    'gui_OutputFcn',  @visualEEG_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before visualEEG is made visible.
function visualEEG_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualEEG (see VARARGIN)

% Choose default command line output for visualizeData
handles.output = hObject;

% Hide most controls
set(handles.bgEpochs, 'Visible', 'Off');
set(handles.upData, 'Visible', 'Off');
set(handles.saveFigure, 'Enable', 'Off');
set(handles.menuExport, 'Enable', 'Off');
set(handles.upOperations, 'Visible', 'Off');
set(handles.toolShowLegend, 'Enable', 'Off');

% Plot instructions
text(0.37,0.5, 'Go to File->Import dataset');

% Add a dataSet cell array
handles.dSets           = {};
handles.datasetNum      = [];

% Set window size  according to optimal ratio
heightRatio = 0.8;
widthRatio = 0.8;

set(0,'units','characters');

displayResolution = get(0,'screensize');

width = displayResolution(3) * widthRatio;
height = displayResolution(4) * heightRatio;
x = (displayResolution(3) - width) / 2;
y = (displayResolution(4) - height) / 2;
set(hObject,'units','characters');
windowPosition = [x y width height];
set(hObject, 'pos', windowPosition);

% Add folders to path
addpath('helpers');
addpath('operations');

% Availabe operations
handles.OPERATIONS = {'Detrend', 'Normalize', 'Abs', 'Remove Common Mode', 'Resample',...
    'Filter', 'FFT', 'Spatial Filter',...
    'Select Channels', 'Create Epochs', 'Exclude Epochs',...
    'Channel Mean', 'Epoch Mean'};


% Update handles structure
guidata(hObject, handles);
% UIWAIT makes visualEEG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = visualEEG_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbPrevious.
function pbPrevious_Callback(hObject, ~, handles)
% hObject    handle to pbPrevious (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dSets(handles.datasetNum).opDataCache{handles.fileNum}.epochNum = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum}.epochNum - 1;
guidata(hObject, handles);
updateView(handles);


% --- Executes on button press in pbNext.
function pbNext_Callback(hObject, ~, handles)
% hObject    handle to pbNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dSets(handles.datasetNum).opDataCache{handles.fileNum}.epochNum = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum}.epochNum + 1;
guidata(hObject, handles);
updateView(handles);


% --- Executes on selection change in pumFile.
function pumFile_Callback(hObject, ~, handles)
% hObject    handle to pumFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumFile
index = get(hObject,'Value');

if(~isempty(handles.dSets(handles.datasetNum).opDataCache{index}))
    handles.fileNum = index;
else
    handles.fileNum = index;
    handles.dSets(handles.datasetNum).ffData.fileNum = index;
    handles.dSets(handles.datasetNum).ffData.fileData = load(fullfile(handles.dSets(handles.datasetNum).ffData.folderName,...
        handles.dSets(handles.datasetNum).ffData.fileNames{index}));
    handles.dSets(handles.datasetNum).ffData.fileName = handles.dSets(handles.datasetNum).ffData.fileNames{index};
    handles.dSets(handles.datasetNum).ffData.fs = handles.dSets(handles.datasetNum).ffData.fileData.(handles.dSets(handles.datasetNum).ffData.fsVariable);
    
    handles.dSets(handles.datasetNum).opDataCache{index} = getOpData(handles.dSets(handles.datasetNum).ffData);
end

guidata(hObject, handles);
updateView(handles);

% --- Executes during object creation, after setting all properties.
function pumFile_CreateFcn(hObject, ~, ~)
% hObject    handle to pum_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in cbDiscard.
function cbDiscard_Callback(hObject, ~, handles)
% hObject    handle to cbDiscard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbDiscard

val = get(hObject,'Value');
if(~isempty(handles.dSets(handles.datasetNum).opDataCache{handles.fileNum}.epochExcludeStatus))
    handles.dSets(handles.datasetNum).opDataCache{handles.fileNum}.epochExcludeStatus(handles.dSets(handles.datasetNum).opDataCache{handles.fileNum}.epochNum) = val;
    guidata(hObject, handles);
    updateView(handles);
end


% --------------------------------------------------------------------
function menuFile_Callback(~, ~, ~)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menuHelp_Callback(~, ~, ~)
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuAbout_Callback(~, ~, ~)
% hObject    handle to menuAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox(sprintf('visualEEG\n\nVersion 2.0\n\nUsman Rashid\nThomas Momme\nUsman Ayub\n\nhttps://github.com/GallVp/visualEEG'), 'About', 'help', 'modal'));

% --------------------------------------------------------------------
function menuImport_Callback(hObject, ~, handles)
% hObject    handle to menuImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


loadedData = importOptionsDlg;

if(isempty(loadedData))
    return;
else
    if(isempty(loadedData.ffData.fileData))
        return;
    end
    
    handles.datasetNum = size(handles.dSets, 2) + 1;
    handles.dSets(handles.datasetNum).ffData = loadedData.ffData;    % ff stands for file folder data
    handles.fileNum = 1; % Selected file number of current data set
    handles.dSets(handles.datasetNum).opDataCache = cell(handles.dSets(handles.datasetNum).ffData.numFiles, 1);
    handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = getOpData(handles.dSets(handles.datasetNum).ffData);
end

% Turn legend off
handles.showLegend = 0;
legend off;
set(handles.toolShowLegend, 'State', 'Off');

%enable most controls
set(handles.bgEpochs, 'Visible', 'On');
set(handles.upData, 'Visible', 'On');
set(handles.upOperations, 'Visible', 'On');
set(handles.menuExport, 'Enable', 'On');
set(handles.saveFigure, 'Enable', 'On');
set(handles.toolShowLegend, 'Enable', 'On');

% Set focus to next
uicontrol(handles.pbNext);

guidata(hObject, handles);
updateView(handles);

function opData = getOpData(ffData) % opData stands for operatable data
opData.channelStream = ffData.fileData.(ffData.dataVariable);
opData.fs = ffData.fs;
opData.abscissa = 1:size(opData.channelStream, 1);
opData.abscissa = opData.abscissa ./ opData.fs;

if(ffData.channelsAcrossRows)
    opData.channelStream = permute(opData.channelStream, [2 1 3]);
end
opData.numChannels = size(opData.channelStream , 2);
opData.numEpochs = size(opData.channelStream , 3);

if(~isempty(ffData.channelNamesVariable))
    opData.channelNames = ffData.fileData.(ffData.channelNamesVariable);
else
    opData.channelNames = {};
end

if(~isempty(ffData.eventVariable))
    opData.events = ffData.fileData.(ffData.eventVariable);
else
    opData.events = [];
end

opData.epochNum = 1;
opData.epochExcludeStatus = [];

% Info on operations
opData.operations = {};
opData.operationArgs = {};



% --------------------------------------------------------------------
function menuExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% saveOptions = exportOptionsDlg;
% if(isempty(saveOptions))
% else
%     switch saveOptions.('selectedOption')
%         case 1%Selected epoch
%             data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
%             data.saveCurrentEpoch(handles.dSets.getDataSet.folderName);
%         case 2%Selected session
%             data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
%             data.saveToFile(handles.dSets.getDataSet.folderName);
%         case 3%Selected subject
%             disp('Export option not implemented');
%         case 4%All subjects
%             disp('Export option not implemented');
%         case 5%Selected Session (NeuCube)
%             try
%                 data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
%                 data.saveNeuCubeData(handles.dSets.getDataSet.folderName);
%             catch ME
%                 uiwait(errordlg(ME.message,'Export NeuCube Data', 'modal'));
%             end
%         otherwise
%             disp('Export option not implemented');
%     end
% end
% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)
% hObject    handle to menuExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;


% --------------------------------------------------------------------
function saveFigure_ClickedCallback(~, ~, handles)
% hObject    handle to saveFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ---Update View function
function updateView(handles)
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
ffData = handles.dSets(handles.datasetNum).ffData;

dat = opData.channelStream;

if(size(dat, 2) > 128)
    disp('Warning: Only plotting first 128 channels');
    dat = dat(:, 1:128);
end
absc = opData.abscissa;

plot(absc, dat(:,:, opData.epochNum));

% Update epoch discard cb enable/disable
if(~isempty(opData.epochExcludeStatus))
    set(handles.cbDiscard, 'Value', opData.epochExcludeStatus(opData.epochNum));
end

% Update dataset selection
set(handles.pumDataSet, 'String', getDataSetNames(handles));
set(handles.pumDataSet, 'Value', handles.datasetNum);

% Update file selection
set(handles.pumFile, 'String', ffData.fileNames);
set(handles.pumFile, 'Value', handles.fileNum);

% Set Visibility of next, previous buttons
if opData.epochNum == opData.numEpochs
    set(handles.pbNext, 'Enable', 'Off');
else
    set(handles.pbNext, 'Enable', 'On');
end
if opData.epochNum == 1
    set(handles.pbPrevious, 'Enable', 'Off');
else
    set(handles.pbPrevious, 'Enable', 'On');
end

% Update value of epoch info control
set(handles.bgEpochs, 'Title', sprintf('Epoch:%d/%d', opData.epochNum, opData.numEpochs));

%update visibility of discard checkbox
if(opData.numEpochs == 1)
    set(handles.cbDiscard, 'Enable', 'Off');
else
    set(handles.cbDiscard, 'Enable', 'On');
end

% Update the operations list
if(~isempty(opData.operations))
    set(handles.lbOperations, 'String', opData.operations);
    set(handles.lbOperations, 'Value', length(opData.operations));
else
    set(handles.lbOperations, 'String', '');
end

% Show legend
if(handles.showLegend)
    legend(opData.channelNames);
end

function dataSetNames = getDataSetNames(handles)
dataSetNames = cell(size(handles.dSets));
for i=1:size(handles.dSets, 2)
    dataSetNames{i} = handles.dSets(i).ffData.folderName;
end


% --- Executes on selection change in lbOperations.
function lbOperations_Callback(hObject, eventdata, handles)
% hObject    handle to lbOperations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbOperations contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbOperations


% --- Executes during object creation, after setting all properties.
function lbOperations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbOperations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbApply.
function cbApply_Callback(hObject, ~, handles)
% hObject    handle to cbApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbApply

val = get(hObject, 'Value');
handles.dSets{handles.datasetNum}.dataStructure.applyOperations(handles.dSets{handles.datasetNum}.dataStructure.fileNum) = val;
guidata(hObject, handles);
updateView(handles);

% --- Executes on button press in pbRemoveOperation.
function pbRemoveOperation_Callback(hObject, ~, handles)
% hObject    handle to pbRemoveOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.lbOperations, 'Value');

opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
opData.operations{index} = [];

opData.operationArgs{index} = [];

opData.operations = opData.operations(~cellfun('isempty',opData.operations));
opData.operationArgs = opData.operationArgs(~cellfun('isempty',opData.operationArgs));

handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opData;

if(~isempty(opData.operations))
    handles = applyAllOps(handles);
else
    handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = getOpData(handles.dSets(handles.datasetNum).ffData);
end
guidata(hObject, handles);
updateView(handles);




% --- Executes on button press in pbAddOperation.
function pbAddOperation_Callback(hObject, ~, handles)
% hObject    handle to pbAddOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[s, v] = listdlg('PromptString','Select an operation:',...
    'SelectionMode','single',...
    'ListString', handles.OPERATIONS);
if(v)
    handles = applyOp(handles, handles.OPERATIONS{s});
end
guidata(hObject, handles);
updateView(handles);

function handlesOut = applyOp(handles, operationName)
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};

% If operation is create epochs, ask for events variable
if(strcmp(operationName, 'Create Epochs') && isempty(handles.dSets(handles.datasetNum).ffData.eventVariable))
    [s,v] = listdlg('PromptString','Select events variable:',...
        'SelectionMode','single',...
        'ListString', handles.dSets(handles.datasetNum).ffData.variableNames);
    if(v)
        handles.dSets(handles.datasetNum).ffData.eventVariable = handles.dSets(handles.datasetNum).ffData.variableNames{s};
        opData.events = handles.dSets(handles.datasetNum).ffData.fileData.(handles.dSets(handles.datasetNum).ffData.eventVariable);
        handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opData;
    else
        handlesOut = handles;
        return;
    end
end

args = askArgs(operationName, opData);
if(isempty(args))% Empty means valid arguments were not provided
    handlesOut = handles;
    return;
end

[opDataOut] = applyOperation(operationName, args, opData);

opDataOut.operations{length(opDataOut.operations) + 1} = operationName;

opDataOut.operationArgs{length(opDataOut.operations)} = args;

handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opDataOut;
handlesOut = handles;

function handlesOut = applyAllOps(handles)
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
freshOpData = getOpData(handles.dSets(handles.datasetNum).ffData);

for i=1:length(opData.operations)
    freshOpData = applyOperation(opData.operations{i},...
        opData.operationArgs{i}, freshOpData);
    freshOpData.operations{i} = opData.operations{i};
    freshOpData.operationArgs{i} = opData.operationArgs{i};
end

handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = freshOpData;
handlesOut = handles;


% --------------------------------------------------------------------
function menuTools_Callback(~, ~, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function toolShowLegend_ClickedCallback(hObject, ~, handles)
% hObject    handle to toolShowLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
if(isempty(opData.channelNames))
    [s,v] = listdlg('PromptString','Select channel names variable:',...
        'SelectionMode','single',...
        'ListString', handles.dSets(handles.datasetNum).ffData.variableNames);
    if(v)
        handles.dSets(handles.datasetNum).ffData.channelNamesVariable = handles.dSets(handles.datasetNum).ffData.variableNames{s};
        opData.channelNames = handles.dSets(handles.datasetNum).ffData.fileData.(handles.dSets(handles.datasetNum).ffData.channelNamesVariable);
        handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opData;
    else
        return;
    end
end

handles.showLegend = ~handles.showLegend;
guidata(hObject, handles);
updateView(handles);


% --- Executes on selection change in pumDataSet.
function pumDataSet_Callback(hObject, ~, handles)
% hObject    handle to pumDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumDataSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumDataSet
index = get(hObject,'Value');
handles.datasetNum = index;
handles.fileNum = handles.dSets(handles.datasetNum).ffData.fileNum;
guidata(hObject, handles);
updateView(handles);


% --- Executes during object creation, after setting all properties.
function pumDataSet_CreateFcn(hObject, ~, ~)
% hObject    handle to pumDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
