function varargout = exportOptionsDlg(varargin)
% EXPORTOPTIONSDLG MATLAB code for exportOptionsDlg.fig
%      EXPORTOPTIONSDLG, by itself, creates a new EXPORTOPTIONSDLG or raises the existing
%      singleton*.
%
%      H = EXPORTOPTIONSDLG returns the handle to a new EXPORTOPTIONSDLG or the handle to
%      the existing singleton*.
%
%      EXPORTOPTIONSDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPORTOPTIONSDLG.M with the given input arguments.
%
%      EXPORTOPTIONSDLG('Property','Value',...) creates a new EXPORTOPTIONSDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before exportOptionsDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to exportOptionsDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help exportOptionsDlg

% Last Modified by GUIDE v2.5 24-Feb-2016 12:35:28

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
                   'gui_OpeningFcn', @exportOptionsDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @exportOptionsDlg_OutputFcn, ...
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



% --- Executes just before exportOptionsDlg is made visible.
function exportOptionsDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to exportOptionsDlg (see VARARGIN)

% Choose default command line output for exportOptionsDlg
handles.output = hObject;

handles.dataOut = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes exportOptionsDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = exportOptionsDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

varargout{1} = handles.dataOut;
delete(hObject);


% --- Executes on selection change in pumOptions.
function pumOptions_Callback(hObject, eventdata, handles)
% hObject    handle to pumOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumOptions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumOptions


% --- Executes during object creation, after setting all properties.
function pumOptions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumOptions (see GCBO)
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
handles.dataOut.('selectedOption') = get(handles.pumOptions, 'Value');
handles.dataOut.('doPreprocess') = get(handles.cbPreprocess, 'Value');
guidata(hObject, handles);
close(handles.figure1);


% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

% --- Executes on button press in cbPreprocess.
function cbPreprocess_Callback(hObject, eventdata, handles)
% hObject    handle to cbPreprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbPreprocess


% --- Executes on button press in cbExcludeTrials.
function cbExcludeTrials_Callback(hObject, eventdata, handles)
% hObject    handle to cbExcludeTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbExcludeTrials


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
