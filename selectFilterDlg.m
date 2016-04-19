function varargout = selectFilterDlg(varargin)
% SELECTFILTERDLG MATLAB code for selectFilterDlg.fig
%      SELECTFILTERDLG, by itself, creates a new SELECTFILTERDLG or raises the existing
%      singleton*.
%
%      H = SELECTFILTERDLG returns the handle to a new SELECTFILTERDLG or the handle to
%      the existing singleton*.
%
%      SELECTFILTERDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTFILTERDLG.M with the given input arguments.
%
%      SELECTFILTERDLG('Property','Value',...) creates a new SELECTFILTERDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before selectFilterDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to selectFilterDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help selectFilterDlg

% Last Modified by GUIDE v2.5 03-Mar-2016 19:34:50

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
                   'gui_OpeningFcn', @selectFilterDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @selectFilterDlg_OutputFcn, ...
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


% --- Executes just before selectFilterDlg is made visible.
function selectFilterDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to selectFilterDlg (see VARARGIN)

% Choose default command line output for selectFilterDlg
handles.output = hObject;

try
    handles.filters = load('savedFilters.mat');
    contents = whos('-file', 'savedFilters.mat');
    filterNames = cell(1, length(contents));
    for i=1:length(contents)
        filterNames{i} = contents(i).name;
    end
    handles.filterNames = filterNames;
    handles.filterNum = 1;
    set(handles.pbSummary, 'Enable', 'On');
    set(handles.pbDelete, 'Enable', 'On');
    set(handles.pbResponse, 'Enable', 'On');
catch me
    if strcmp(me.identifier, 'MATLAB:load:couldNotReadFile')
        handles.filters = [];
        handles.filterNames = {'None'};
        set(handles.pbSummary, 'Enable', 'Off');
        set(handles.pbDelete, 'Enable', 'Off');
        set(handles.pbResponse, 'Enable', 'Off');
        set(handles.pbOK, 'Enable', 'Off');
    end
end
set(handles.pumFilters, 'String', handles.filterNames);
handles.dataOut = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes selectFilterDlg wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = selectFilterDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.dataOut;
delete(hObject);


% --- Executes on selection change in pumFilters.
function pumFilters_Callback(hObject, eventdata, handles)
% hObject    handle to pumFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumFilters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumFilters
handles.filterNum = get(hObject, 'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pumFilters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumFilters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbNew.
function pbNew_Callback(hObject, eventdata, handles)
% hObject    handle to pbNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
while(1)
    prompt = {'Enter filter name:'};
    dlg_title = 'Filter Name';
    num_lines = 1;
    defaultans = {''};
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    if(~isempty(answer))
        TF = strcmp(answer{1}, handles.filterNames);
        if(sum(TF))
            choice = questdlg('Filter already exists. Want to replace?', ...
                'Overwrite', ...
                'OK', 'Cancel', 'Cancel');
            if(strcmp(choice, 'Cancel'))
                continue;
            else
                handles.filters.(answer{1}) = designfilt;
                if(isempty(handles.filters.(answer{1})))
                    break;
                else
                    filters = handles.filters;
                    save('savedFilters.mat', '-struct', 'filters');
                    contents = whos('-file', 'savedFilters.mat');
                    filterNames = cell(1, length(contents));
                    for i=1:length(contents)
                        filterNames{i} = contents(i).name;
                    end
                    handles.filterNames = filterNames;
                    handles.filterNum = length(filterNames);
                    set(handles.pumFilters, 'String', handles.filterNames);
                    set(handles.pumFilters, 'Value', handles.filterNum);
                    break;
                end
            end
        else
            handles.filters.(answer{1}) = designfilt;
            if(isempty(handles.filters.(answer{1})))
                break;
            else
                filters = handles.filters;
                save('savedFilters.mat', '-struct', 'filters');
                contents = whos('-file', 'savedFilters.mat');
                filterNames = cell(1, length(contents));
                for i=1:length(contents)
                    filterNames{i} = contents(i).name;
                end
                handles.filterNames = filterNames;
                handles.filterNum = length(filterNames);
                set(handles.pumFilters, 'String', handles.filterNames);
                set(handles.pumFilters, 'Value', handles.filterNum);
                set(handles.pbSummary, 'Enable', 'On');
                set(handles.pbDelete, 'Enable', 'On');
                set(handles.pbResponse, 'Enable', 'On');
                set(handles.pbOK, 'Enable', 'On');
                break;
            end
        end
    else
        break;
    end
end
guidata(hObject, handles);

% --- Executes on button press in pbOK.
function pbOK_Callback(hObject, eventdata, handles)
% hObject    handle to pbOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dataOut.selectedFilter = handles.filters.(handles.filterNames{handles.filterNum});
guidata(hObject, handles);
close(handles.figure1);

% --- Executes on button press in pbSummary.
function pbSummary_Callback(hObject, eventdata, handles)
% hObject    handle to pbSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox(info(handles.filters.(handles.filterNames{handles.filterNum})),'Filter', 'modal')

% --- Executes on button press in pbEdit.
function pbEdit_Callback(hObject, eventdata, handles)
% hObject    handle to pbEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbDelete.
function pbDelete_Callback(hObject, eventdata, handles)
% hObject    handle to pbDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.filters = rmfield(handles.filters, handles.filterNames{handles.filterNum});
filters = handles.filters;
if(isempty(fieldnames(filters)))
    delete('savedFilters.mat')
    handles.filters = [];
    handles.filterNames = {'None'};
    handles.filterNum = 1;
    set(handles.pbSummary, 'Enable', 'Off');
    set(handles.pbDelete, 'Enable', 'Off');
    set(handles.pbResponse, 'Enable', 'Off');
    set(handles.pbOK, 'Enable', 'Off');
else
    save('savedFilters.mat', '-struct', 'filters');
    contents = whos('-file', 'savedFilters.mat');
    filterNames = cell(1, length(contents));
    for i=1:length(contents)
        filterNames{i} = contents(i).name;
    end
    handles.filterNames = filterNames;
    handles.filterNum = 1;
end
guidata(hObject, handles);
set(handles.pumFilters, 'String', handles.filterNames);
set(handles.pumFilters, 'Value', handles.filterNum);

% --- Executes on button press in pbCancel.
function pbCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pbCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


% --- Executes on button press in pbResponse.
function pbResponse_Callback(hObject, eventdata, handles)
% hObject    handle to pbResponse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fvtool(handles.filters.(handles.filterNames{handles.filterNum}));


% --- Executes during object creation, after setting all properties.
function pbEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
