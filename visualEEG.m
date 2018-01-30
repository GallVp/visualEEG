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

% Availabe operations
handles.OPERATIONS = {'Detrend', 'Normalize', 'Abs', 'Remove Common Mode', 'Resample', 'Delay',...
    'Filter', 'FFT', 'Spatial Filter',...
            'Channel Mean', 'Epoch Mean',...
            'Threshold by Std.' 'PCA', 'FAST ICA'};


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
handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied).previousEpoch;
guidata(hObject, handles);
updateView(handles);


% --- Executes on button press in pbNext.
function pbNext_Callback(hObject, ~, handles)
% hObject    handle to pbNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied).nextEpoch;
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
dataStructure = handles.dSets{handles.datasetNum}.dataStructure;
dataStructure.fileNum = index;
dataStructure.fileName = dataStructure.fileNames{index};
dataStructure.fileData = load(fullfile(dataStructure.folderName,...
    dataStructure.fileName));

if(dataStructure.channelsAcrossRows)
    dataStructure.numChannels = size(dataStructure.fileData.(dataStructure.dataVariable), 1);
else
    dataStructure.numChannels = size(dataStructure.fileData.(dataStructure.dataVariable), 2);
end

lia = ismember(dataStructure.selectedChannels, 1:dataStructure.numChannels);
if(sum(lia) ~= length(lia))
    dataStructure.selectedChannels = 1:dataStructure.numChannels;
end

% Load every time in case channel names are different. Furthermore contains
% operation can take a long time, so no need to perform it
if(~isempty(dataStructure.channelNamesVariable))
    dataStructure.channelNames = dataStructure.fileData.(dataStructure.channelNamesVariable);
end

% Load sampling frequency
if(~isempty(dataStructure.fsVariable))
    dataStructure.fs = dataStructure.fileData.(dataStructure.fsVariable);
end

% Load num of epochs
dataStructure.numEpochs = size(dataStructure.fileData.(dataStructure.dataVariable), 3);
if(dataStructure.epochNum > dataStructure.numEpochs)
    dataStructure.epochNum = 1;
end

handles.dSets{handles.datasetNum}.dataStructure = dataStructure;
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
absoluteEpochNum = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(...
    handles.dSets.getOperationSuperSet.isApplied).getAbsoluteEpochNum;
handles.dSets.getDataSet.updateEpochExStatus(absoluteEpochNum, ~val);
guidata(hObject, handles);
updateView(handles);


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
uiwait(msgbox(sprintf('Visual EEG\n\nVersion 2.0\n\nUsman Rashid\nurashid@aut.ac.nz\n\nhttps://github.com/GallVp/visualEEG'), 'About', 'help', 'modal'));

% --------------------------------------------------------------------
function menuImport_Callback(hObject, ~, handles)
% hObject    handle to menuImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    loadedData = importOptionsDlg;
    
    if(isempty(loadedData))
        return;
    else
        if(isempty(loadedData.dataStructure.fileData))
            return;
        end
        
        % Add some extra variables to dataStructure
        loadedData.dataStructure.fileNum = 1;
        loadedData.dataStructure.channelNames = {};
        loadedData.dataStructure.channelNamesVariable = [];
        if(loadedData.dataStructure.channelsAcrossRows)
            loadedData.dataStructure.numChannels = size(loadedData.dataStructure.fileData.(loadedData.dataStructure.dataVariable), 1);
            loadedData.dataStructure.selectedChannels = 1:loadedData.dataStructure.numChannels;
        else
            loadedData.dataStructure.numChannels = size(loadedData.dataStructure.fileData.(loadedData.dataStructure.dataVariable), 2);
            loadedData.dataStructure.selectedChannels = 1:loadedData.dataStructure.numChannels;
        end
        
        loadedData.dataStructure.numEpochs = size(loadedData.dataStructure.fileData.(loadedData.dataStructure.dataVariable), 3);
        loadedData.dataStructure.epochNum = 1;
        
        handles.datasetNum = size(handles.dSets, 2) + 1;
        handles.dSets{handles.datasetNum} = loadedData;
    end
    
    % Turn legend off
    handles.showLegend = 0;
    legend off;
    set(handles.toolShowLegend, 'State', 'Off');
    
    % turn off cues
    handles.showCues = 0;
    
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
catch ME
    errordlg(ME.message,'Data import', 'modal');
    disp(ME);
end

% --------------------------------------------------------------------
function menuExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveOptions = exportOptionsDlg;
if(isempty(saveOptions))
else
    switch saveOptions.('selectedOption')
        case 1%Selected epoch
            data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
            data.saveCurrentEpoch(handles.dSets.getDataSet.folderName);
        case 2%Selected session
            data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
            data.saveToFile(handles.dSets.getDataSet.folderName);
        case 3%Selected subject
            disp('Export option not implemented');
        case 4%All subjects
            disp('Export option not implemented');
        case 5%Selected Session (NeuCube)
            try
                data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
                data.saveNeuCubeData(handles.dSets.getDataSet.folderName);
            catch ME
                uiwait(errordlg(ME.message,'Export NeuCube Data', 'modal'));
            end
        otherwise
            disp('Export option not implemented');
    end
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
data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
% h = findobj(gca,'Type','line');
% figXData = get(h, 'XData');
% figYData = get(h, 'YData');

H = figure;
verbose = 1;
data.plotCurrentEpoch(handles.showCues, handles.showLegend, verbose);

[~,~,~] = mkdir(handles.dSets.getDataSet.folderName, 'Output Figures');
imgName = fullfile(strcat(handles.dSets.getDataSet.folderName, '/Output Figures'),...
    sprintf('sub%02d_sess%02d_%s.pdf',handles.dSets.getDataSet.subjectNum, handles.dSets.getDataSet.sessionNum,...
    datestr(now)));
try
    export_fig(imgName, '-transparent', H);
    uiwait(msgbox(imgName,'Saved image...','modal'));
catch ME
    uiwait(errordlg('Failed to export using export_fig. Now using matlab print function.','Figure export', 'modal'));
    print(imgName, '-dpdf', H);
    uiwait(msgbox(imgName,'Saved image...','modal'));
end
close(H);

% ---Update View function
function updateView(handles)
dataStructure = handles.dSets{handles.datasetNum}.dataStructure;
dat = dataStructure.fileData.(dataStructure.dataVariable);

% Make channels across columns
if(dataStructure.channelsAcrossRows)
    dat = transpose(dat);
end
if(size(dat, 2) > 128)
    disp('Warning: Only plotting first 128 channels');
    dat = dat(:, 1:128);
end

% Select channels
dat = dat(:, dataStructure.selectedChannels);

% Calculate absc
if(~isempty(dataStructure.fs))
    absc = 1:size(dat, 1);
    absc = absc ./ dataStructure.fs;
else
    absc = 1:size(dat, 1);
end

plot(absc, dat);

% Update dataset selection
set(handles.pumDataSet, 'String', getDataSetNames(handles));
set(handles.pumDataSet, 'Value', handles.datasetNum);

% Update file selection
set(handles.pumFile, 'String', dataStructure.fileNames);
set(handles.pumFile, 'Value', dataStructure.fileNum);

% Update channels list
if(~isempty(dataStructure.channelNames))
    set(handles.editChannels, 'String', strjoin(dataStructure.channelNames(dataStructure.selectedChannels)));
    
else
    set(handles.editChannels, 'String', num2str(dataStructure.selectedChannels));
end

% Set Visibility of next, previous buttons
if dataStructure.epochNum == dataStructure.numEpochs
    set(handles.pbNext, 'Enable', 'Off');
else
    set(handles.pbNext, 'Enable', 'On');
end
if dataStructure.epochNum == 1
    set(handles.pbPrevious, 'Enable', 'Off');
else
    set(handles.pbPrevious, 'Enable', 'On');
end

% Update value of epoch info control
set(handles.bgEpochs, 'Title', sprintf('Epoch:%d/%d', dataStructure.epochNum, dataStructure.numEpochs));

%update visibility of discard checkbox
if(dataStructure.numEpochs == 1)
    set(handles.cbDiscard, 'Enable', 'Off');
else
    set(handles.cbDiscard, 'Enable', 'On');
end

function dataSetNames = getDataSetNames(handles)
dataSetNames = cell(size(handles.dSets));
for i=1:size(handles.dSets, 2)
    dataSetNames{i} = handles.dSets{i}.dataStructure.folderName;
end

% data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);
%
% % Update the operations list
% set(handles.lbOperations, 'String', handles.dSets.getOperationSuperSet.getOperationSet.operations);
% set(handles.lbOperations, 'Value', length(handles.dSets.getOperationSuperSet.getOperationSet.operations));
%
% % Update Operation Sets list
% set(handles.pumOpsSet, 'String', handles.dSets.getOperationSuperSet.names);
% set(handles.pumOpsSet, 'Value', handles.dSets.getOperationSuperSet.operationSetNum);
%
%
% set(handles.pumSession, 'String', num2str(handles.dSets.getDataSet.listSessions));
% set(handles.pumSession, 'Value', handles.dSets.getDataSet.getSessionSrNo);
%
% set(handles.pumFile, 'String', num2str(handles.dSets.getDataSet.listSubjects));
% set(handles.pumFile, 'Value', handles.dSets.getDataSet.getSubjectSrNo);
%
% set(handles.editIntvl1, 'String', num2str(handles.dSets.getDataSet.interval(1)));
% set(handles.editIntvl2, 'String', num2str(handles.dSets.getDataSet.interval(2)));
%
% set(handles.cbExcludeEpochs, 'Value', handles.dSets.getDataSet.exEpochsOnOff);
%
% set(handles.editGroupNum, 'Value', handles.dSets.getDataSet.groupNum);
% set(handles.editNumGroups, 'Value', handles.dSets.getDataSet.numGroups);
%
%
% %Update enable and checked property of apply
% if isempty(handles.dSets.getOperationSuperSet.getOperationSet.operations)
%     set(handles.cbApply, 'Enable', 'Off');
%     set(handles.pbRemoveOperation, 'Enable', 'Off');
%     set(handles.cbApply, 'Value', 0);
% else
%     set(handles.cbApply, 'Enable', 'On');
%     set(handles.pbRemoveOperation, 'Enable', 'On');
%     set(handles.cbApply, 'Value', handles.dSets.getOperationSuperSet.isApplied);
% end
%
%
% %Update plot
% verbose = 0;
% data.plotCurrentEpoch(handles.showCues, handles.showLegend, verbose);
%
% %Update trial number to be displayed
% % totalEpochs = size(viewData, 3);
% % if(totalEpochs == 1)
% %     epochNum = 1;
% % else
% %     epochNum = handles.epochNum;
% % end
%
%
%
% %Show epoch info
%
%


function editChannels_Callback(hObject, ~, handles)
% hObject    handle to editChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editChannels as text
%        str2double(get(hObject,'String')) returns contents of editChannels as a double

dataStructure = handles.dSets{handles.datasetNum}.dataStructure;

channels = get(hObject,'String');
channelNames = strsplit(strtrim(channels));
channelNums = str2num(channels);
if(~isnan(channelNums))
    lia = ismember(channelNums, 1:dataStructure.numChannels);
    if(sum(lia) == length(lia))
        dataStructure.selectedChannels = channelNums;
        handles.dSets{handles.datasetNum}.dataStructure = dataStructure;
        guidata(hObject, handles);
        updateView(handles);
    else
        h = errordlg(sprintf('Wrong channel(s) selected.\nAvailable Channels: %s', num2str(1:dataStructure.numChannels)),...
            'Channel selection', 'modal');
        uiwait(h);
        updateView(handles);
    end
elseif(~isempty(dataStructure.channelNames))
    lia = ismember(channelNames, dataStructure.channelNames);
    if(sum(lia) == length(lia))
        dataStructure.selectedChannels = strcmpIND(dataStructure.channelNames, channelNames);
        handles.dSets{handles.datasetNum}.dataStructure = dataStructure;
        guidata(hObject, handles);
        updateView(handles);
    else
        h = errordlg(sprintf('Wrong channel(s) selected.\nAvailable Channels: %s', strjoin(dataStructure.channelNames, ' ')),...
            'Channel selection', 'modal');
        uiwait(h);
        updateView(handles);
    end
else
    h = errordlg(sprintf('Wrong channel(s) selected.\nAvailable Channels: %s', num2str(1:dataStructure.numChannels)),...
        'Channel selection', 'modal');
    uiwait(h);
    updateView(handles);
end


% --- Executes during object creation, after setting all properties.
function editChannels_CreateFcn(hObject, ~, handles)
% hObject    handle to editChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSelectChannels.
function pbSelectChannels_Callback(hObject, ~, handles)
% hObject    handle to pbSelectChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataStructure = handles.dSets{handles.datasetNum}.dataStructure;
chanNames = dataStructure.channelNames;
if(isempty(chanNames))
    [s,v] = listdlg('PromptString','Select channel names variable:',...
        'SelectionMode','single',...
        'ListString', dataStructure.variableNames);
    if(v)
        dataStructure.channelNamesVariable = dataStructure.variableNames{s};
        dataStructure.channelNames = dataStructure.fileData.(dataStructure.channelNamesVariable);
    else
        return;
    end
end

chanNames = dataStructure.channelNames;
[channels,~] = listdlg('PromptString','Select channels:',...
    'ListString', chanNames);
if(~isempty(channels))
    channelNames = chanNames(channels,:);
    
    dataStructure.selectedChannels = strcmpIND(dataStructure.channelNames, channelNames);
    
    set(handles.editChannels,'String', strjoin(channelNames));
    
    handles.dSets{handles.datasetNum}.dataStructure = dataStructure;
    guidata(hObject, handles);
    updateView(handles);
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
handles.dSets.getOperationSuperSet.setApplied(val);
guidata(hObject, handles);
updateView(handles);

% --- Executes on button press in pbRemoveOperation.
function pbRemoveOperation_Callback(hObject, ~, handles)
% hObject    handle to pbRemoveOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.lbOperations, 'Value');

handles.dSets.getOperationSuperSet.getOperationSet.rmOperation(index);
guidata(hObject, handles);
updateView(handles);


% --- Executes on button press in pbAddOperation.
function pbAddOperation_Callback(hObject, ~, handles)
% hObject    handle to pbAddOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dSets.getOperationSuperSet.getOperationSet.addOperation;
handles.dSets.getOperationSuperSet.setApplied(1);
guidata(hObject, handles);
updateView(handles);


% --- Executes on button press in cbExcludeEpochs.
function cbExcludeEpochs_Callback(hObject, ~, handles)
% hObject    handle to cbExcludeEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbExcludeEpochs

val = get(hObject, 'Value');
handles.dSets.getDataSet.excludeEpochs(val);
guidata(hObject, handles);
updateView(handles);


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


% --- Executes during object creation, after setting all properties.
function pbSelectChannels_CreateFcn(~, ~, ~)
% hObject    handle to pbSelectChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
