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


% Last Modified by GUIDE v2.5 01-Jul-2016 12:26:02

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
set(handles.menuView, 'Enable', 'Off');

% Plot instructions
text(0.37,0.5, 'Go to File->Import dataset');

% Add a dataSets class to the GUI
handles.dSets = dataSets;

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


% --- Executes on selection change in pumSubject.
function pumSubject_Callback(hObject, ~, handles)
% hObject    handle to pumSubject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumSubject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumSubject
index = get(hObject,'Value');
lst = handles.dSets.getDataSet.listSubjects;
subjectNum = lst(index);

handles.dSets.getDataSet.selectSub(subjectNum);
guidata(hObject, handles);
updateView(handles);


% --- Executes on selection change in pumSession.
function pumSession_Callback(hObject, eventdata, handles)
% hObject    handle to pumSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumSession contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumSession
index = get(hObject,'Value');
lst = handles.dSets.getDataSet.listSessions;
sessionNum = lst(index);

handles.dSets.getDataSet.selectSess(sessionNum);
guidata(hObject, handles);
updateView(handles);


% --- Executes during object creation, after setting all properties.
function pumSession_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pumSubject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pum_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editIntvl1_Callback(hObject, eventdata, handles)
% hObject    handle to editIntvl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIntvl1 as text
%        str2num(get(hObject,'String')) returns contents of editIntvl1 as a double
val = get(hObject,'String');
intvl1 = str2double(val);

if(~isnan(intvl1))
    try
        handles.dSets.getDataSet.selectInterval([intvl1 handles.dSets.getDataSet.interval(2)]);
        guidata(hObject, handles);
        updateView(handles);
    catch ME
        errordlg(ME.message,'Interval selection', 'modal');
        set(hObject,'String', num2str(handles.dSets.getDataSet.interval(1)));
    end
end

% --- Executes during object creation, after setting all properties.
function editIntvl1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIntvl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editIntvl2_Callback(hObject, eventdata, handles)
% hObject    handle to editIntvl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIntvl2 as text
%        str2num(get(hObject,'String')) returns contents of editIntvl2 as a double
val = get(hObject,'String');
intvl2 = str2double(val);

if(~isnan(intvl2))
    try
        handles.dSets.getDataSet.selectInterval([handles.dSets.getDataSet.interval(1) intvl2]);
        guidata(hObject, handles);
        updateView(handles);
    catch ME
        errordlg(ME.message,'Interval selection', 'modal');
        set(hObject,'String', num2str(handles.dSets.getDataSet.interval(2)));
    end
end


% --- Executes during object creation, after setting all properties.
function editIntvl2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIntvl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in cbDiscard.
function cbDiscard_Callback(hObject, eventdata, handles)
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
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox(sprintf('Visual EEG\n\nVersion 1.0\n\nUsman Rashid\nurashid@aut.ac.nz\nAUT New Zealand'), 'About', 'help', 'modal'));

% --------------------------------------------------------------------
function menuImport_Callback(hObject, eventdata, handles)
% hObject    handle to menuImport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
handles.dSets.addDataSet;
%Set operations box

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
set(handles.menuView, 'Enable', 'On');

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
        case 1%Window data
        case 2%Selected trial
        case 3%Selected session
            if(saveOptions.('doPreprocess') == 1)
                [mydata, ~, ~] = handles.operationSets{1,2}.getProcData(handles.dSets.getOperationSuperSet.isApplied);
            else
                mydata = handles.dataSet1.sstData;
            end
            uisave({'mydata'},fullfile(handles.folderName,...
                sprintf('vEEG_sub%02d_sess%02d',handles.subjectNum, handles.sessionNum)));
        case 4%Selected subject
        case 5%All subjects
        case 6%NeuCube
    end
end
% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)
% hObject    handle to menuExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;

% --------------------------------------------------------------------
function menu_export_neucube_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export_neucube (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function saveFigure_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to saveFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj(gca,'Type','line');
figXData = get(h, 'XData');
figYData = get(h, 'YData');
H = figure;
if(iscell(figXData))
    hold on;
    for i=1:size(figXData, 1)
        plot(cell2mat(figXData(i,1)), cell2mat(figYData(i,1)), 'linewidth', 2);
    end
    hold off;
else
    plot(figXData, figYData, 'linewidth', 2);
end
xlabel('Time (s)')
ylabel('Amplitude')
set(gca,'FontName','Helvetica');
set(gca,'FontSize',12);
set(gca,'LineWidth',2);
set(H,'Color',[1 1 1]);
[~,~,~] = mkdir(handles.folderName, 'Output Figures');
export_fig(fullfile(strcat(handles.folderName, '/Output Figures'),...
    sprintf('sub%02d_sess%02d_%s.pdf',handles.subjectNum, handles.sessionNum,...
    datestr(now))));
close(H);

% ---Update View function
function updateView(handles)

data = handles.dSets.getOperationSuperSet.getOperationSet.getProcData(handles.dSets.getOperationSuperSet.isApplied);

% Update the operations list
set(handles.lbOperations, 'String', handles.dSets.getOperationSuperSet.getOperationSet.operations);
set(handles.lbOperations, 'Value', length(handles.dSets.getOperationSuperSet.getOperationSet.operations));

% Update Operation Sets list
set(handles.pumOpsSet, 'String', handles.dSets.getOperationSuperSet.names);
set(handles.pumOpsSet, 'Value', handles.dSets.getOperationSuperSet.operationSetNum);

%Update data selection
set(handles.pumDataSet, 'String', handles.dSets.names);
set(handles.pumDataSet, 'Value', handles.dSets.dataSetNum);

set(handles.pumSession, 'String', num2str(handles.dSets.getDataSet.listSessions));
set(handles.pumSession, 'Value', handles.dSets.getDataSet.getSessionSrNo);

set(handles.pumSubject, 'String', num2str(handles.dSets.getDataSet.listSubjects));
set(handles.pumSubject, 'Value', handles.dSets.getDataSet.getSubjectSrNo);

set(handles.editChannels, 'String', strjoin(handles.dSets.getDataSet.listChannelNames));

set(handles.editIntvl1, 'String', num2str(handles.dSets.getDataSet.interval(1)));
set(handles.editIntvl2, 'String', num2str(handles.dSets.getDataSet.interval(2)));

set(handles.cbExcludeEpochs, 'Value', handles.dSets.getDataSet.exEpochsOnOff);

set(handles.editGroupNum, 'Value', handles.dSets.getDataSet.groupNum);
set(handles.editNumGroups, 'Value', handles.dSets.getDataSet.numGroups);


%Update enable and checked property of apply
if isempty(handles.dSets.getOperationSuperSet.getOperationSet.operations)
    set(handles.cbApply, 'Enable', 'Off');
    set(handles.pbRemoveOperation, 'Enable', 'Off');
    set(handles.cbApply, 'Value', 0);
else
    set(handles.cbApply, 'Enable', 'On');
    set(handles.pbRemoveOperation, 'Enable', 'On');
    set(handles.cbApply, 'Value', handles.dSets.getOperationSuperSet.isApplied);
end


%Update plot
dispEpoch = data.getEpoch;
if(isempty(dispEpoch))
    axis([0 1 0 1]);
    text(0.38,0.5, 'No epochs available.');
else
    if(strcmp(data.dataType, sstData.DATA_TYPE_TIME_SERIES) || strcmp(data.dataType, sstData.DATA_TYPE_GRAND_TIME_SERIES))
        plot(data.abscissa, dispEpoch)
    else
        stem(data.abscissa, dispEpoch)
    end
end

% if(handles.staticCue)
%     hold on
%     a = axis;
%     line([handles.cueTime handles.cueTime], [a(3) a(4)], 'LineStyle','--', 'Color', 'red', 'LineWidth', 1);
%     axis(a);
%     hold off
% end
% if(handles.dynamicCue)
%     hold on
%     a = axis;
%     ext = cell2mat(handles.cues(cell2mat(handles.cues(:,1))==handles.subjectNum & cell2mat(handles.cues(:,2))==handles.sessionNum,3));
%     try
%         cueTime = ext(handles.epochNum);
%         line([cueTime+handles.dynamicCueOffset cueTime+handles.dynamicCueOffset], [a(3) a(4)],...
% 'LineStyle','--', 'Color', 'blue', 'LineWidth', 1);
%     catch ME
%         disp(ME)
%         disp('Probable cause: Dynamic cues not available for selected subject/session.')
%     end
%     axis(a);
%     hold off
% end


%Update Legend
if(handles.showLegend)
    legend(data.channelNames);
else
    legend off
end

%Update trial number to be displayed
% totalEpochs = size(viewData, 3);
% if(totalEpochs == 1)
%     epochNum = 1;
% else
%     epochNum = handles.epochNum;
% end



%Show epoch info

set(handles.bgEpochs, 'Title', sprintf('Epoch:%d (%d)/%d; Excluded:%d', data.getAbsoluteEpochNum(data.currentEpochNum),...
    data.currentEpochNum, data.dataSize(3), data.numExcludedEpochs));

% Set Visibility of next, previous buttons
if data.isLastEpoch
    set(handles.pbNext, 'Enable', 'Off');
else
    set(handles.pbNext, 'Enable', 'On');
end
if data.isFirstEpoch
    set(handles.pbPrevious, 'Enable', 'Off');
else
    set(handles.pbPrevious, 'Enable', 'On');
end

%update visibility of discard checkbox
if(data.currentEpochNum == 0 || strcmp(data.dataType, sstData.DATA_TYPE_GRAND_FREQUENCY_SERIES)...
        || strcmp(data.dataType, sstData.DATA_TYPE_GRAND_TIME_SERIES))
    set(handles.cbDiscard, 'Enable', 'Off');
else
    set(handles.cbDiscard, 'Enable', 'On');
    set(handles.cbDiscard, 'Value', ~handles.dSets.getDataSet.getEpochExStatus(data.currentEpochNum));
end


function editChannels_Callback(hObject, eventdata, handles)
% hObject    handle to editChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editChannels as text
%        str2double(get(hObject,'String')) returns contents of editChannels as a double
channels = get(hObject,'String');
channelNames = strsplit(strtrim(channels));
channelNums = str2num(channels);
if(~isnan(channelNums))
    lia = ismember(channelNums, handles.dSets.getDataSet.listAllChannelNums);
    if(sum(lia) == length(lia))
        handles.dSets.getDataSet.selectChannels(channelNums);
        guidata(hObject, handles);
        updateView(handles);
    else
        errordlg('Wrong channel(s) selected.','Channel selection', 'modal');
        set(hObject, 'String', strjoin(handles.dSets.getDataSet.listChannelNames));
    end
else
    lia = ismember(channelNames, handles.dSets.getDataSet.listAllChannelNames);
    if(sum(lia) == length(lia))
        handles.dSets.getDataSet.selectChannelsByName(channelNames);
        guidata(hObject, handles);
        updateView(handles);
    else
        errordlg('Wrong channel(s) selected.','Channel selection', 'modal');
        set(hObject, 'String', strjoin(handles.dSets.getDataSet.listChannelNames));
    end
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
function pbSelectChannels_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
chanNames = handles.dSets.getDataSet.listAllChannelNames;
[channels,~] = listdlg('PromptString','Select channels:',...
                'ListString', chanNames);
if(~isempty(channels))
    channelNames = chanNames(channels,:);
    handles.dSets.getDataSet.selectChannelsByName(channelNames);
    set(handles.editChannels,'String', strjoin(channelNames));
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
function cbApply_Callback(hObject, eventdata, handles)
% hObject    handle to cbApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbApply

val = get(hObject, 'Value');
handles.dSets.getOperationSuperSet.setApplied(val);
guidata(hObject, handles);
updateView(handles);

% --- Executes on button press in pbRemoveOperation.
function pbRemoveOperation_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemoveOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.lbOperations, 'Value');

handles.dSets.getOperationSuperSet.getOperationSet.rmOperation(index);
guidata(hObject, handles);
updateView(handles);


% --- Executes on button press in pbAddOperation.
function pbAddOperation_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dSets.getOperationSuperSet.getOperationSet.addOperation;
handles.dSets.getOperationSuperSet.setApplied(1);
guidata(hObject, handles);
updateView(handles);


% --- Executes on button press in cbExcludeEpochs.
function cbExcludeEpochs_Callback(hObject, eventdata, handles)
% hObject    handle to cbExcludeEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbExcludeEpochs

val = get(hObject, 'Value');
handles.dSets.getDataSet.excludeEpochs(val);
guidata(hObject, handles);
updateView(handles);


% --- Executes on selection change in pumOpsSet.
function pumOpsSet_Callback(hObject, eventdata, handles)
% hObject    handle to pumOpsSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumOpsSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumOpsSet
index = get(hObject,'Value');

handles.dSets.getOperationSuperSet.selectOperationSet(index);

guidata(hObject, handles);
updateView(handles);


% --- Executes during object creation, after setting all properties.
function pumOpsSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumOpsSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbAddOpsSet.
function pbAddOpsSet_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddOpsSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.dSets.getOperationSuperSet.addOperationSet)
    % Update operations controls
    guidata(hObject, handles);
    updateView(handles);
end


% --- Executes on button press in pbRemoveOpsSet.
function pbRemoveOpsSet_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemoveOpsSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    handles.dSets.getOperationSuperSet.rmOperationSet;
    guidata(hObject, handles);
    updateView(handles);
catch ME
    errordlg(ME.message,'Cue insertion', 'modal');
end


% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function toolShowLegend_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to toolShowLegend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.showLegend = ~handles.showLegend;
guidata(hObject, handles);
updateView(handles);


% --------------------------------------------------------------------
function menuView_Callback(hObject, eventdata, handles)
% hObject    handle to menuView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuAxisLimits_Callback(hObject, eventdata, handles)
% hObject    handle to menuAxisLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a = axis;
prompt = {'Xmin:','Xmax:','Ymin:','Ymax:'};
dlg_title = 'Axis limits';
num_lines = 1;
defaultans = {num2str(a(1)),num2str(a(2)),num2str(a(3)),num2str(a(4))};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if(isempty(answer))
    return;
else
    axis([str2double(answer{1}) str2double(answer{2}) str2double(answer{3}) str2double(answer{4})]);
end


% --- Executes on selection change in pumDataSet.
function pumDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to pumDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumDataSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumDataSet
index = get(hObject,'Value');
handles.dSets.selectDataSet(index);
guidata(hObject, handles);
updateView(handles);


% --- Executes during object creation, after setting all properties.
function pumDataSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNumGroups_Callback(hObject, eventdata, handles)
% hObject    handle to editNumGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumGroups as text
%        str2double(get(hObject,'String')) returns contents of editNumGroups as a double

val = get(hObject,'String');
numGroups = str2double(val);

if(~isnan(numGroups))
    try
        handles.dSets.getDataSet.selectEpochGroup(numGroups, handles.dSets.getDataSet.groupNum);
        guidata(hObject, handles);
        updateView(handles);
    catch ME
        errordlg(ME.message,'Group selection', 'modal');
        set(hObject,'String', num2str(handles.dSets.getDataSet.numGroups));
    end
end


% --- Executes during object creation, after setting all properties.
function editNumGroups_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumGroups (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editGroupNum_Callback(hObject, eventdata, handles)
% hObject    handle to editGroupNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editGroupNum as text
%        str2double(get(hObject,'String')) returns contents of editGroupNum as a double
val = get(hObject,'String');
groupNum = str2double(val);

if(~isnan(groupNum))
    try
        handles.dSets.getDataSet.selectEpochGroup(handles.dSets.getDataSet.numGroups, groupNum);
        guidata(hObject, handles);
        updateView(handles);
    catch ME
        errordlg(ME.message,'Group selection', 'modal');
        set(hObject,'String', num2str(handles.dSets.getDataSet.groupNum));
    end
end

% --- Executes during object creation, after setting all properties.
function editGroupNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editGroupNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSuperAddOpsSet.
function pbSuperAddOpsSet_Callback(hObject, eventdata, handles)
% hObject    handle to pbSuperAddOpsSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.dSets.getOperationSuperSet.superAddOperationSet)
    % Update operations controls
    guidata(hObject, handles);
    updateView(handles);
end
