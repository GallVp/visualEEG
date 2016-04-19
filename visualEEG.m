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

% Last Modified by GUIDE v2.5 09-Mar-2016 15:36:02

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
set(handles.bg_trial, 'Visible', 'Off');
set(handles.up_data, 'Visible', 'Off');
set(handles.saveFigure, 'Enable', 'Off');
set(handles.menu_export, 'Enable', 'Off');
set(handles.menuTools, 'Enable', 'Off');
set(handles.upOperations, 'Visible', 'Off');

% Plot instructions
text(0.38,0.5, 'Go to File->Import data');

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


% --- Executes on button press in pb_previous.
function pb_previous_Callback(hObject, ~, handles)
% hObject    handle to pb_previous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.trialNum = handles.trialNum - 1;
guidata(hObject, handles);
updateView(handles);


% --- Executes on button press in pb_next.
function pb_next_Callback(hObject, ~, handles)
% hObject    handle to pb_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.trialNum = handles.trialNum + 1;
guidata(hObject, handles);
updateView(handles);


% --- Executes on selection change in pum_subject.
function pum_subject_Callback(hObject, ~, handles)
% hObject    handle to pum_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pum_subject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pum_subject
index = get(hObject,'Value');
lst = handles.dataSet1.listSubjects;
handles.subjectNum = lst(index);

lst = handles.dataSet1.listSessions(handles.subjectNum);
set(handles.pum_session, 'String', num2str(lst));
set(handles.pum_session, 'Value', 1);
handles.sessionNum = lst(1);

% Reset trial number back to 1.
handles.trialNum = 1;

handles.dataSet1.loadData(handles.subjectNum, handles.sessionNum);
for i = 1:size(handles.operationSets, 1)
    handles.operationSets{i,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
end
guidata(hObject, handles);
updateView(handles);


% --- Executes on selection change in pum_session.
function pum_session_Callback(hObject, eventdata, handles)
% hObject    handle to pum_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pum_session contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pum_session
index = get(hObject,'Value');
lst = handles.dataSet1.listSessions;
handles.sessionNum = lst(index);

% Reset trial number back to 1.
handles.trialNum = 1;

handles.dataSet1.loadData(handles.subjectNum, handles.sessionNum);
for i = 1:size(handles.operationSets, 1)
    handles.operationSets{i,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
end
guidata(hObject, handles);
updateView(handles);


% --- Executes during object creation, after setting all properties.
function pum_session_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pum_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pum_subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pum_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_intvl1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intvl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intvl1 as text
%        str2num(get(hObject,'String')) returns contents of edit_intvl1 as a double
val = get(hObject,'String');
intvl1 = str2double(val);

if(~isnan(intvl1))
    if(intvl1 >= handles.intvl2 || intvl1 < 0 || intvl1 > handles.dataSet1.trialTime)
        errordlg('Invalid interval.','Interval selection', 'modal');
        set(hObject, 'String', num2str(handles.intvl1));
    else
        handles.intvl1 = intvl1;
        handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
        guidata(hObject, handles);
        updateView(handles);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_intvl1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intvl1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_intvl2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intvl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intvl2 as text
%        str2num(get(hObject,'String')) returns contents of edit_intvl2 as a double
val = get(hObject,'String');
intvl2 = str2double(val);

if(~isnan(intvl2))
    if(intvl2 <= handles.intvl1 || intvl2 < 0 || intvl2 > handles.dataSet1.trialTime)
        errordlg('Invalid interval.','Interval selection', 'modal');
        set(hObject, 'String', num2str(handles.intvl2));
    else
        handles.intvl2 = intvl2;
        handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
        guidata(hObject, handles);
        updateView(handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_intvl2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intvl2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in cb_discard.
function cb_discard_Callback(hObject, eventdata, handles)
% hObject    handle to cb_discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_discard

val = get(hObject,'Value');
handles.dataSet1.updateTrialExStatus(handles.trialNum, val);
handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox(sprintf('Visual EEG\n\nVersion 1.0\n\nUsman Rashid\nurashid@aut.ac.nz\nAUT New Zealand'), 'About', 'help', 'modal'));

% --------------------------------------------------------------------
function menu_import_Callback(hObject, eventdata, handles)
% hObject    handle to menu_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataOut = importOptionsDlg;
if ~isempty(dataOut)
    folderName = uigetdir;
    if folderName ~=0
        handles.folderName = folderName;
        % Initilize a data class and a operations class
        handles.dataSet1 = eegData;
        %Set Operations Set Info
        handles.operationSets = {'Set 1', eegOperations, 0, 0};
        handles.operationSetNum = 1;
        handles.operationSets{handles.operationSetNum,2}.attachDataSet(handles.dataSet1);
        try
            handles.dataSet1.anchorFolder(folderName, dataOut.sampleRate, dataOut.importMethod,...
                dataOut.trialTime, dataOut.beforeIndex, dataOut.afterIndex);
        catch ME
            if (strcmp(ME.identifier,'eegData:load:noFileFound'))
                 errordlg('Folder does not contain any valid data file(s).','Import Data', 'modal');
                 return
            end
        end
        
        %Set operations box
        set(handles.lbOperations, 'String', '');
        set(handles.lbOperations, 'Value', 1);
        
        
        %Startup data selection
        lst = handles.dataSet1.listSessions;
        handles.sessionNum = lst(1);
        set(handles.pum_session, 'String', num2str(handles.dataSet1.listSessions));
        set(handles.pum_session, 'Value', 1);
        
        lst = handles.dataSet1.listSubjects;
        handles.subjectNum = lst(1);
        set(handles.pum_subject, 'String', num2str(handles.dataSet1.listSubjects));
        set(handles.pum_subject, 'Value', 1);
        
        handles.trialNum = 1;
        
        lst = handles.dataSet1.listChannels;
        handles.channels = lst(1);
        set(handles.editChannels, 'String', num2str(lst(1)));
        
        handles.intvl1 = 0;
        set(handles.edit_intvl1, 'String', num2str(handles.intvl1));
        handles.intvl2 = handles.dataSet1.trialTime;
        set(handles.edit_intvl2, 'String', num2str(handles.intvl2));
        

        set(handles.cbApply, 'Value', 0);
        set(handles.cbExcludeEpochs, 'Value', 0);
        
        handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
        guidata(hObject, handles);
        updateView(handles);
        
        %enable most controls
        set(handles.bg_trial, 'Visible', 'On');
        set(handles.up_data, 'Visible', 'On');
        set(handles.upOperations, 'Visible', 'On');
        
        set(handles.menu_export, 'Enable', 'On');
        
        set(handles.saveFigure, 'Enable', 'On');
        
        set(handles.menuTools, 'Enable', 'On');
    end
end

% --------------------------------------------------------------------
function menu_export_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveOptions = exportOptionsDlg;
if(isempty(saveOptions))
else
    switch saveOptions.('selectedOption')
        case 1%Window data
        case 2%Selected trial
        case 3%Selected session
        case 4%Selected subject
        case 5%All subjects
        case 6%NeuCube
    end
end
% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
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
    plot(cell2mat(figXData(1,1)), cell2mat(figYData), 'linewidth', 2);
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

% Update the operations list
set(handles.lbOperations, 'String', handles.operationSets{handles.operationSetNum,2}.operations);
set(handles.lbOperations, 'Value', length(handles.operationSets{handles.operationSetNum,2}.operations));

if handles.operationSets{handles.operationSetNum,3} && ~isempty(handles.operationSets{handles.operationSetNum,2}.operations)
    [viewData, abscissa, dataDomain] = handles.operationSets{handles.operationSetNum,2}.getProcData;
else
    viewData = handles.dataSet1.sstData(:,handles.channels,:);
    abscissa = 0:1/handles.dataSet1.dataRate:handles.dataSet1.trialTime;
    dataDomain = {'Time'};
end


%Update plot
[xData, yData] = computePlotData(viewData, abscissa, dataDomain, handles);
if(strcmp(dataDomain, {'Time'}))
    plot(xData, yData)
else
    stem(xData, yData)
end


totalEpochs = size(viewData, 3);
if(totalEpochs == 1)
    trialNum = 1;
else
    trialNum = handles.trialNum;
end
%update view
if handles.operationSets{handles.operationSetNum,3} && ~isempty(handles.operationSets{handles.operationSetNum,2}.operations)
    set(handles.cb_discard, 'Visible', 'Off');
    set(handles.bg_trial, 'Title', sprintf('Epoch:%d/%d', trialNum, totalEpochs));
else
    set(handles.cb_discard, 'Visible', 'On');
    set(handles.cb_discard, 'Value', handles.dataSet1.extrials(1, trialNum));
    set(handles.bg_trial, 'Title', sprintf('Epoch:%d/%d; Excluded:%d', trialNum, totalEpochs, sum(handles.dataSet1.extrials)));
end

if trialNum == totalEpochs
    set(handles.pb_next, 'Enable', 'Off');
else
    set(handles.pb_next, 'Enable', 'On');
end
if trialNum == 1
    set(handles.pb_previous, 'Enable', 'Off');
else
    set(handles.pb_previous, 'Enable', 'On');
end

function [xData, yData] = computePlotData(viewData, abscissa, dataDomain, handles)
indices = computeIndices(handles);
if(strcmp(dataDomain, {'Time'}))
xData = abscissa(indices(1):indices(2));
datasize = size(viewData);
if(length(datasize) == 2)
    yData = viewData(indices(1):indices(2),:);
else
    yData = viewData(indices(1):indices(2),:,handles.trialNum);
end
else
   xData = abscissa;
   datasize = size(viewData);
   if(length(datasize) == 2)
       yData = viewData(:,:);
   else
       yData = viewData(:,:,handles.trialNum);
   end
end

function [indices] = computeIndices(handles)
indices = [handles.intvl1+1/handles.dataSet1.dataRate handles.intvl2] .* handles.dataSet1.dataRate;

function editChannels_Callback(hObject, eventdata, handles)
% hObject    handle to editChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editChannels as text
%        str2double(get(hObject,'String')) returns contents of editChannels as a double
val = get(hObject,'String');
channels = str2num(val);

if(~isnan(channels))
    lia = ismember(channels, handles.dataSet1.listChannels);
    if(sum(lia) == length(lia))
        handles.channels = channels;
        for i = 1:size(handles.operationSets, 1)
            handles.operationSets{i,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
        end
        guidata(hObject, handles);
        updateView(handles);
    else
        errordlg('Wrong channel(s) selected.','Channel selection', 'modal');
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
handles.operationSets{handles.operationSetNum,3} = val;
guidata(hObject, handles);
updateView(handles);

% --- Executes on button press in pbRemoveOperation.
function pbRemoveOperation_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemoveOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = get(handles.lbOperations, 'Value');

handles.operationSets{handles.operationSetNum,2}.rmOperation(index);
handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
updateView(handles);


% --- Executes on button press in pbAddOperation.
function pbAddOperation_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddOperation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[s,~] = listdlg('PromptString','Select a operation:', 'SelectionMode','single', 'ListString',eegOperations.AVAILABLE_OPERATIONS);
if(isempty(s))
    return
end
if(handles.operationSets{handles.operationSetNum,2}.addOperation(s))
    updateView(handles);
end


% --- Executes on button press in cbExcludeEpochs.
function cbExcludeEpochs_Callback(hObject, eventdata, handles)
% hObject    handle to cbExcludeEpochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbExcludeEpochs

val = get(hObject, 'Value');
handles.operationSets{handles.operationSetNum,4} = val;
handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});
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

handles.operationSetNum = index;

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
prompt = {'Enter operation set name:'};
dlg_title = 'Name';
num_lines = 1;
defaultans = {''};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
if(~isempty(answer))
    handles.operationSetNum = size(handles.operationSets, 1) + 1;
    handles.operationSets(handles.operationSetNum, :) = {answer{1}, eegOperations, 0, 0};
    % Update operations controls
    set(handles.cbApply, 'Value', handles.operationSets{handles.operationSetNum,3});
    set(handles.cbExcludeEpochs, 'Value', handles.operationSets{handles.operationSetNum,4});
    % Update opsSet List
    set(handles.pumOpsSet, 'String', handles.operationSets(:,1));
    set(handles.pumOpsSet, 'Value', handles.operationSetNum);
    handles.operationSets{handles.operationSetNum,2}.attachDataSet(handles.dataSet1);
    handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});

    guidata(hObject, handles);
    updateView(handles);
end


% --- Executes on button press in pbRemoveOpsSet.
function pbRemoveOpsSet_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemoveOpsSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.operationSetNum == 1)
    errordlg('Default operation set can not be deleted.','Operation Set Error', 'modal');
else
    handles.operationSets(handles.operationSetNum, :) = [];
    handles.operationSetNum = 1;
    % Update operations controls
    set(handles.cbApply, 'Value', handles.operationSets{handles.operationSetNum,3});
    set(handles.cbExcludeEpochs, 'Value', handles.operationSets{handles.operationSetNum,4});
    % Update opsSet List
    set(handles.pumOpsSet, 'String', handles.operationSets(:,1));
    set(handles.pumOpsSet, 'Value', handles.operationSetNum);
    handles.operationSets{handles.operationSetNum,2}.attachDataSet(handles.dataSet1);
    handles.operationSets{handles.operationSetNum,2}.updateDataInfo(handles.channels,[handles.intvl1 handles.intvl2], handles.operationSets{handles.operationSetNum,4});

    guidata(hObject, handles);
    updateView(handles);
end


% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuMatchedFilter_Callback(hObject, eventdata, handles)
% hObject    handle to menuMatchedFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataIn.('dataSet') = copy(handles.dataSet1);
dataIn.('channels') = handles.channels;
gMatchedFilter(dataIn);

% --------------------------------------------------------------------
function menuSvm_Callback(hObject, eventdata, handles)
% hObject    handle to menuSvm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataIn.('dataSet') = copy(handles.dataSet1);
dataIn.('channels') = handles.channels;
gSVM(dataIn);
