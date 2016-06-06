function varargout = importOptionsDlg(varargin)
% IMPORTOPTIONSDLG MATLAB code for importOptionsDlg.fig
%      IMPORTOPTIONSDLG, by itself, creates a new IMPORTOPTIONSDLG or raises the existing
%      singleton*.
%
%      H = IMPORTOPTIONSDLG returns the handle to a new IMPORTOPTIONSDLG or the handle to
%      the existing singleton*.
%
%      IMPORTOPTIONSDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTOPTIONSDLG.M with the given input arguments.
%
%      IMPORTOPTIONSDLG('Property','Value',...) creates a new IMPORTOPTIONSDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before importOptionsDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to importOptionsDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help importOptionsDlg

% Last Modified by GUIDE v2.5 06-Jun-2016 11:48:18

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
                   'gui_OpeningFcn', @importOptionsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @importOptionsDlg_OutputFcn, ...
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


% --- Executes just before importOptionsDlg is made visible.
function importOptionsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to importOptionsDlg (see VARARGIN)

% Choose default command line output for importOptionsDlg
handles.output = hObject;

%Defaults
set(handles.upByEpochIndex, 'Visible', 'Off');
set(handles.upByTrialTime, 'Visible', 'On');
handles.dataOut = [];
handles.importMethod = 'BYTRIALTIME';
handles.sampleRate = str2num(get(handles.editSampleRate, 'String'));
handles.trialTime = str2num(get(handles.editTrialTime, 'String'));
handles.beforeIndex = str2num(get(handles.editBeforeIndex, 'String'));
handles.afterIndex = str2num(get(handles.editAfterIndex, 'String'));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes importOptionsDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = importOptionsDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.dataOut;
delete(hObject);



function editSampleRate_Callback(hObject, eventdata, handles)
% hObject    handle to editSampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSampleRate as text
%        str2double(get(hObject,'String')) returns contents of editSampleRate as a double


% --- Executes during object creation, after setting all properties.
function editSampleRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSampleRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbOk.
function pbOk_Callback(hObject, eventdata, handles)
% hObject    handle to pbOk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dataOut.('importMethod') = handles.importMethod;
handles.dataOut.('sampleRate') = str2num(get(handles.editSampleRate, 'String'));
handles.dataOut.('beforeIndex') = str2num(get(handles.editBeforeIndex, 'String'));
handles.dataOut.('afterIndex') = str2num(get(handles.editAfterIndex, 'String'));
if(strcmp(handles.importMethod, 'BYEPOCHINDEX'))
    handles.dataOut.('trialTime') = str2num(get(handles.editBeforeIndex, 'String'))...
        + str2num(get(handles.editAfterIndex, 'String'));
else
    handles.dataOut.('trialTime') = str2num(get(handles.editTrialTime, 'String'));
end
guidata(hObject, handles);
close(handles.figure1);

% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);


function editTrialTime_Callback(hObject, eventdata, handles)
% hObject    handle to editTrialTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTrialTime as text
%        str2double(get(hObject,'String')) returns contents of editTrialTime as a double


% --- Executes during object creation, after setting all properties.
function editTrialTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTrialTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAfterIndex_Callback(hObject, eventdata, handles)
% hObject    handle to editAfterIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAfterIndex as text
%        str2double(get(hObject,'String')) returns contents of editAfterIndex as a double


% --- Executes during object creation, after setting all properties.
function editAfterIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAfterIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editBeforeIndex_Callback(hObject, eventdata, handles)
% hObject    handle to editBeforeIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBeforeIndex as text
%        str2double(get(hObject,'String')) returns contents of editBeforeIndex as a double


% --- Executes during object creation, after setting all properties.
function editBeforeIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBeforeIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbByTrialTime.
function rbByTrialTime_Callback(hObject, eventdata, handles)
% hObject    handle to rbByTrialTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbByTrialTime
handles.importMethod = 'BYTRIALTIME';
set(handles.upByTrialTime, 'Visible', 'On');
set(handles.upByEpochIndex, 'Visible', 'Off');
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end


% --- Executes on button press in rbByEpochIndex.
function rbByEpochIndex_Callback(hObject, eventdata, handles)
% hObject    handle to rbByEpochIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbByEpochIndex
handles.importMethod = 'BYEPOCHINDEX';
set(handles.upByTrialTime, 'Visible', 'Off');
set(handles.upByEpochIndex, 'Visible', 'On');
guidata(hObject, handles);


% --- Executes on button press in rbEmgCueFiles.
function rbEmgCueFiles_Callback(hObject, eventdata, handles)
% hObject    handle to rbEmgCueFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbEmgCueFiles
handles.importMethod = 'EMGCUEFILES';
set(handles.upByTrialTime, 'Visible', 'Off');
set(handles.upByEpochIndex, 'Visible', 'Off');
guidata(hObject, handles);
