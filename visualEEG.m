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
%
% Edit the above text to modify the response to help visualEEG
%
% Last Modified by GUIDE v2.5 27-Apr-2018 10:57:59
%
% Copyright (c) <2016> <Usman Rashid>
% Licensed under the MIT License. See License.txt in the project root for
% license information.

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
set(handles.menuTools, 'Enable', 'Off');
set(handles.menuOptions, 'Enable', 'Off');
set(handles.menuSaveToOutFold, 'Enable', 'Off');
set(handles.menuOperations, 'Enable', 'Off');
set(handles.upOperations, 'Visible', 'Off');
set(handles.toolShowLegend, 'Enable', 'Off');
set(handles.toolSaveToOutFold, 'Enable', 'Off');
set(handles.exportFig, 'Enable', 'Off');


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

if(isdeployed)
    rootDir = ctfroot;
    % Load funcs from the operations folder
    handles.OPERATIONS = loadFuncs(fullfile(rootDir, 'operations'));
else
    % Add folders to path
    addpath(genpath('libs'));
    addpath('operations');
    
    % Load funcs from the operations folder
    handles.OPERATIONS = loadFuncs('operations');
end

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
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
opData.epochNum = opData.epochNum - 1;
handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opData;
handlesOut = updateView(handles);
guidata(hObject, handlesOut);


% --- Executes on button press in pbNext.
function pbNext_Callback(hObject, ~, handles)
% hObject    handle to pbNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
opData.epochNum = opData.epochNum + 1;
handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opData;
handlesOut = updateView(handles);
guidata(hObject, handlesOut);


% --- Executes on selection change in pumFile.
function pumFile_Callback(hObject, ~, handles)
% hObject    handle to pumFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumFile contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumFile
index = get(hObject,'Value');

if(index == handles.fileNum)
    return;
end
% save old file num in case for operation overwrite
oldFileNum = handles.fileNum;
handles.fileNum = index;
handles.dSets(handles.datasetNum).ffData.fileNum = index;
handles.dSets(handles.datasetNum).ffData.fileData = load(fullfile(handles.dSets(handles.datasetNum).ffData.folderName,...
    handles.dSets(handles.datasetNum).ffData.fileNames{index}));
handles.dSets(handles.datasetNum).ffData.fileName = handles.dSets(handles.datasetNum).ffData.fileNames{index};

if(isempty(handles.dSets(handles.datasetNum).opDataCache{index}))
    handles.dSets(handles.datasetNum).opDataCache{index} = getOpData(handles.dSets(handles.datasetNum).ffData);
end

% If apply all files is true, overwrite all operations in the new loaded
% file only if the newly loaded file does not have the same operations.
val = get(handles.menuOperateAllFiles, 'Check');
if(strcmp(val, 'on'))
    opDataOld = handles.dSets(handles.datasetNum).opDataCache{oldFileNum};
    opDataNew = handles.dSets(handles.datasetNum).opDataCache{index};
    if(isempty(opDataNew.operations) || length(opDataOld.operations) ~= length(opDataNew.operations))
        handles = applyAllOps(opDataOld.operations, opDataOld.operationArgs, handles);
    else
        opCompare = strcmp(opDataOld.operations, opDataNew.operations);
        if(sum(opCompare) ~= length(opCompare))
            handles = applyAllOps(opDataOld.operations, opDataOld.operationArgs, handles);
        end
    end
end

handlesOut = updateView(handles);
guidata(hObject, handlesOut);

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
    handlesOut = updateView(handles);
    guidata(hObject, handlesOut);
end


% --------------------------------------------------------------------
function menuFile_Callback(hObject, ~, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);

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
fileID = fopen('about.txt','r');
ln = fgets(fileID);
abt = '';
while ischar(ln)
    abt = sprintf('%s %s', abt, ln);
    ln = fgets(fileID);
end
fclose(fileID);
[iconImage, iconMap, iconAlpha] = imread('icon.png');
mH  = msgbox(sprintf('%s', abt), 'About', 'custom', iconImage, iconMap, 'modal');
set(mH.Children(2).Children, 'AlphaData', iconAlpha);
uiwait(mH);

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
set(handles.menuTools, 'Enable', 'On');
set(handles.menuOptions, 'Enable', 'On');
set(handles.saveFigure, 'Enable', 'On');
set(handles.menuOperations, 'Enable', 'On');
set(handles.toolShowLegend, 'Enable', 'On');
set(handles.exportFig, 'Enable', 'On');


% Set focus to next
uicontrol(handles.pbNext);

handlesOut = updateView(handles);
guidata(hObject, handlesOut);

function opData = getOpData(ffData) % opData stands for operatable data.
% This is the structure which is passed around visualEEG functions.
opData.channelStream = ffData.fileData.(ffData.dataVariable);
if(isempty(ffData.fsVariable))
    opData.fs = ffData.fs;
else
    opData.fs = ffData.fileData.(ffData.fsVariable);
end

if(ffData.channelsAcrossRows)
    opData.channelStream = permute(opData.channelStream, [2 1 3]);
end

% Compute abscissa
opData.abscissa = 1:size(opData.channelStream, 1);
opData.abscissa = opData.abscissa ./ opData.fs;

opData.numChannels = size(opData.channelStream , 2);
opData.numEpochs = size(opData.channelStream , 3);

opData.channelNames = {};
opData.events = [];

%** Additional variables being added for better conformity
% However, these variables sould be during data export.
opData.fileVariableNames    = ffData.variableNames;
opData.fileData             = ffData.fileData;
opData.epochNum = 1;
% Custom updateView function
opData.updateView = [];
% Legend info
opData.legendInfo = {};
%** End Additional

opData.epochExcludeStatus = zeros(size(opData.channelStream, 3), 1);

% Info on operations
opData.operations = {};
opData.operationArgs = {};



% --------------------------------------------------------------------
function menuExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles.dSets(handles.datasetNum), 'outputFolder'))
    [file, path] = uiputfile('*.mat','Save processed data as', handles.dSets(handles.datasetNum).outputFolder);
else
    [file, path] = uiputfile('*.mat','Save processed data as');
end
if path ~= 0
    filePath = fullfile(path, file);
    opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
    % Remove attached additional variables
    opData = rmfield(opData, 'fileData');
    opData = rmfield(opData, 'fileVariableNames');
    opData = rmfield(opData, 'epochNum');
    opData = rmfield(opData, 'legendInfo');
    opData = rmfield(opData, 'updateView');
    save(filePath, '-struct', 'opData');
end

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

set(0,'showhiddenhandles','on'); % Make the GUI figure handle visible
h = findobj(gcf,'type','axes'); % Find the axes object in the GUI
l = findobj(gcf,'type','legend'); % Find the legend object in the GUI
f1 = figure; % Open a new figure with handle f1
copyobj([h l],f1); % Copy axes object h into figure f1
axisOfH = gca;
set(axisOfH, 'ActivePositionProperty','outerposition');
set(axisOfH, 'Units','normalized');
set(axisOfH, 'OuterPosition',[0 0 1 1]);
set(axisOfH, 'position',[0.1300 0.1100 0.7750 0.8150]);
set(axisOfH, 'LineWidth', 2);
set(axisOfH, 'FontSize', 14);
set(axisOfH, 'Box', 'Off');
set(axisOfH.Children, 'LineWidth', 2);

% ---Update View function
function handlesOut = updateView(handles)
handlesOut = handles;
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
ffData = handles.dSets(handles.datasetNum).ffData;

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

% Call custom updateView if it exists
if(~isempty(opData.updateView))
    axH = gca;
    opData = opData.updateView(axH, opData);
    handlesOut.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opData;
else
    
    % Plot data
    dat = opData.channelStream;
    
    if(size(dat, 2) > 128)
        disp('Warning: Only plotting first 128 channels');
        dat = dat(:, 1:128);
    end
    absc = opData.abscissa;
    
    plot(absc, dat(:,:, opData.epochNum));
    % Set axis labels
    xlabel('Time (s)');
    ylabel('Amplitude');
end

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

% Show legend
if(handles.showLegend && ~isempty(opData.legendInfo))
    legend(opData.legendInfo);
end

% Set toolSaveToOutFold enable status
if(isfield(handles.dSets(handles.datasetNum), 'outputFolder'))
    set(handles.toolSaveToOutFold, 'Enable', 'On');
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

if(~isempty(opData.operations))
    handles = applyAllOps(opData.operations, opData.operationArgs, handles);
else
    handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = getOpData(handles.dSets(handles.datasetNum).ffData);
end
handlesOut = updateView(handles);
guidata(hObject, handlesOut);


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
handlesOut = updateView(handles);
guidata(hObject, handlesOut);

function handlesOut = applyOp(handles, operationName)
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};

% Convert operation name to handle
fHandle = str2func(operationName);
[argFunc, opFunc] = fHandle();

args = argFunc(opData);
if(isempty(args))% Empty means valid arguments were not provided
    handlesOut = handles;
    return;
else
    [opDataOut] = opFunc(opData, args);
    
    opDataOut.operations{length(opDataOut.operations) + 1} = operationName;
    
    opDataOut.operationArgs{length(opDataOut.operations)} = args;
    
    handles.dSets(handles.datasetNum).opDataCache{handles.fileNum} = opDataOut;
    handlesOut = handles;
end

function handlesOut = applyAllOps(operations, operationArgs, handles)
freshOpData = getOpData(handles.dSets(handles.datasetNum).ffData);

for i=1:length(operations)
    operationName = operations{i};
    % Convert operation name to handle;
    fHandle = str2func(operationName);
    [~, opFunc] = fHandle();
    freshOpData = opFunc(freshOpData, operationArgs{i});
    freshOpData.operations{i} = operations{i};
    freshOpData.operationArgs{i} = operationArgs{i};
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
if(isempty(opData.legendInfo))
    return;
end

handles.showLegend = ~handles.showLegend;
handlesOut = updateView(handles);
guidata(hObject, handlesOut);


% --- Executes on selection change in pumDataSet.
function pumDataSet_Callback(hObject, ~, handles)
% hObject    handle to pumDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumDataSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumDataSet
index = get(hObject,'Value');
if(handles.datasetNum ~= index)
    handles.datasetNum = index;
    handles.fileNum = handles.dSets(handles.datasetNum).ffData.fileNum;
    handlesOut = updateView(handles);
    guidata(hObject, handlesOut);
end


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


% --------------------------------------------------------------------
function menuImportOps_Callback(hObject, eventdata, handles)
% hObject    handle to menuImportOps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile('*.csv');
if file ~=0
    [operations, operationArgs] = importOpearions(fullfile(path, file));
    handlesOut = applyAllOps(operations, operationArgs, handles);
    handlesOut = updateView(handlesOut);
    guidata(hObject, handlesOut);
end


% --------------------------------------------------------------------
function menuExportOps_Callback(hObject, eventdata, handles)
% hObject    handle to menuExportOps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
if(isempty(opData.operations))
    h = errordlg('No operations to export', 'Export Operations', 'modal');
    uiwait(h);
    return;
end
filter = {'*.csv'};
[file, path] = uiputfile(filter);
if file ~=0
    exportOpearions(opData.operations, opData.operationArgs, fullfile(path, file));
end


% --------------------------------------------------------------------
function menuOptions_Callback(hObject, eventdata, handles)
% hObject    handle to menuOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles.dSets(handles.datasetNum), 'outputFolder'))
    set(handles.menuSetOutFold, 'Label', 'Change output folder');
else
    set(handles.menuSetOutFold, 'Label', 'Set output folder');
end


% --------------------------------------------------------------------
function menuSetOutFold_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetOutFold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isfield(handles.dSets(handles.datasetNum), 'outputFolder'))
    selpath = uigetdir(handles.dSets(handles.datasetNum).outputFolder);
else
    selpath = uigetdir;
end

if selpath ~= 0
    set(handles.menuSaveToOutFold, 'Enable', 'On');
    set(handles.toolSaveToOutFold, 'Enable', 'On');
    handles.dSets(handles.datasetNum).outputFolder = selpath;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function menuSaveToOutFold_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveToOutFold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = handles.dSets(handles.datasetNum).ffData.fileName;
path = handles.dSets(handles.datasetNum).outputFolder;
filePath = fullfile(path, file);
opData = handles.dSets(handles.datasetNum).opDataCache{handles.fileNum};
% Remove attached additional variables
opData = rmfield(opData, 'fileData');
opData = rmfield(opData, 'fileVariableNames');
opData = rmfield(opData, 'epochNum');
opData = rmfield(opData, 'legendInfo');
opData = rmfield(opData, 'updateView');
save(filePath, '-struct', 'opData');
set(handles.toolSaveToOutFold, 'Enable', 'Off');
guidata(hObject, handles);


% --------------------------------------------------------------------
function menuOperateAllFiles_Callback(hObject, eventdata, handles)
% hObject    handle to menuOperateAllFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.menuOperateAllFiles, 'Check');
if(strcmp(val, 'on'))
    val = 'off';
else
    val = 'on';
end
set(handles.menuOperateAllFiles, 'Check', val);


% --------------------------------------------------------------------
function menuAutoReapply_Callback(hObject, eventdata, handles)
% hObject    handle to menuAutoReapply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuOperations_Callback(hObject, eventdata, handles)
% hObject    handle to menuOperations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function toolSaveToOutFold_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to toolSaveToOutFold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menuSaveToOutFold_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function exportFig_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to exportFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter = {'*.pdf';'*.png';'*.eps';'*.tiff';'*.jpg';'*.bmp'};
[file, path] = uiputfile(filter);
if file == 0
    return;
end
set(0, 'showhiddenhandles','on'); % Make the GUI figure handle visible
h = findobj(gcf,'type','axes'); % Find the axes object in the GUI
l = findobj(gcf,'type','legend'); % Find the legend object in the GUI
f1 = figure('Visible', 'off'); % Open a new figure with handle f1
copyobj([h l],f1); % Copy axes object h into figure f1
axisOfH = gca;
set(axisOfH, 'ActivePositionProperty','outerposition');
set(axisOfH, 'Units','normalized');
set(axisOfH, 'OuterPosition',[0 0 1 1]);
set(axisOfH, 'position',[0.1300 0.1100 0.7750 0.8150]);
set(axisOfH, 'LineWidth', 2);
set(axisOfH, 'FontSize', 14);
set(axisOfH, 'Box', 'Off');
set(axisOfH.Children, 'LineWidth', 2);

% For pdf and eps try export_fig. For rest use, MATLAB print. 
printFilter = {'*.png';'*.tiff';'*.jpg';'*.bmp'};
[~, ~, ext] = fileparts(fullfile(path, file));
filterSpec = sprintf('*%s', ext);
if(sum(strcmp(filterSpec, printFilter)))
    formatSpec = sprintf('-d%s', ext(2:end));
    print(fullfile(path, file), formatSpec, f1, '-r600');
else
    try
        export_fig(fullfile(path, file), '-transparent', f1);
    catch ME
        uiwait(errordlg(sprintf('Failed to export using "export_fig". Now using MATLAB "print" function.\nMATLAB "print" produces poor quality graphics.\n\nFor optimal quality, please make sure you have following softwares installed:\n1. gs: http://www.ghostscript.com\n2. pdftops: http://www.xpdfreader.com'),'Figure export', 'modal'));
        formatSpec = sprintf('-d%s', ext(2:end));
        print(fullfile(path, file), formatSpec, f1, '-r600');
    end
end
delete(f1);
