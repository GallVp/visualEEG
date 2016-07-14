function varargout = combineDataDlg(varargin)
% COMBINEDATADLG MATLAB code for combineDataDlg.fig
%      COMBINEDATADLG, by itself, creates a new COMBINEDATADLG or raises the existing
%      singleton*.
%
%      H = COMBINEDATADLG returns the handle to a new COMBINEDATADLG or the handle to
%      the existing singleton*.
%
%      COMBINEDATADLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMBINEDATADLG.M with the given input arguments.
%
%      COMBINEDATADLG('Property','Value',...) creates a new COMBINEDATADLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before combineDataDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to combineDataDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright (c) <2016> <Usman Rashid>
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.  See the file
% LICENSE included with this distribution for more information.

% Edit the above text to modify the response to help combineDataDlg

% Last Modified by GUIDE v2.5 06-Jul-2016 16:02:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @combineDataDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @combineDataDlg_OutputFcn, ...
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


% --- Executes just before combineDataDlg is made visible.
function combineDataDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to combineDataDlg (see VARARGIN)

% Choose default command line output for combineDataDlg
handles.output = hObject;

dataIn = varargin{1};

handles.dSets = dataIn.('dSets');
handles.availableCombinations = dataIn.('availableCombinations');

set(handles.pumDataSets, 'String', handles.dSets.names);
set(handles.pumDataSets, 'Value', 1);

set(handles.pumCombine, 'String', handles.availableCombinations);
set(handles.pumCombine, 'Value', 1);

set(handles.pumOperationSets, 'String', handles.dSets.getOperationSuperSet(1).names);
set(handles.pumCombine, 'Value', 1);

% Default dataOut
handles.dataOut = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes combineDataDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = combineDataDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.dataOut;
delete(hObject);


% --- Executes on selection change in pumCombine.
function pumCombine_Callback(hObject, eventdata, handles)
% hObject    handle to pumCombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumCombine contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumCombine
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function pumCombine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumCombine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pumDataSets.
function pumDataSets_Callback(hObject, eventdata, handles)
% hObject    handle to pumDataSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumDataSets contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumDataSets
set(handles.pumOperationSets, 'String', handles.dSets.getOperationSuperSet(get(hObject, 'Value')).names);
set(handles.pumCombine, 'Value', 1);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function pumDataSets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumDataSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pumOperationSets.
function pumOperationSets_Callback(hObject, eventdata, handles)
% hObject    handle to pumOperationSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumOperationSets contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumOperationSets

% --- Executes during object creation, after setting all properties.
function pumOperationSets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumOperationSets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dataOut.('combinationNum') = get(handles.pumCombine, 'Value');
handles.dataOut.('operationSetNum') = get(handles.pumOperationSets, 'Value');
handles.dataOut.('dataSetNum') = get(handles.pumDataSets, 'Value');
guidata(hObject, handles);
close(handles.figure1);

% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dataOut = [];
guidata(hObject, handles);
close(handles.figure1);

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
