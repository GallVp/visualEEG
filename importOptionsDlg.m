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

% Last Modified by GUIDE v2.5 30-Jan-2018 13:58:10

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

% Constants
handles.MAX_CHANNELS = 128;

%Defaults
handles.dataOut = [];

% Startup data
handles.dataStructure = [];

% Update handles structure
guidata(hObject, handles);

% View setup
heightRatio = 0.5;
widthRatio = 0.5;
set(0,'units','characters');

displayResolution = get(0,'screensize');

width = displayResolution(3) * widthRatio;
height = displayResolution(4) * heightRatio;
x_x = (displayResolution(3) - width) / 2;
y = (displayResolution(4) - height) / 2;
set(handles.figure1,'units','characters');
windowPosition = [x_x y width height];
set(handles.figure1, 'pos', windowPosition);


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
handles.dataStructure.fs = str2double(get(handles.editSampleRate, 'String'));
guidata(hObject, handles);


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
handles.dataStructureDefault.fs                 = str2double(get(handles.editSampleRate, 'String'));
handles.dataStructureDefault.dataVariable       = get(handles.editDataVariable, 'String');
handles.dataStructureDefault.eventVariable      = get(handles.editEventVariable, 'String');
handles.dataStructureDefault.channelsAcrossRows = get(handles.cbChannAcrossRow, 'Value');
handles.dataStructureDefault.fileNames          = [];
handles.dataStructureDefault.fileName           = [];     % Name of the loaded file
handles.dataStructureDefault.fileData           = [];
handles.dataStructureDefault.folderName         = [];
handles.dataStructureDefault.fsVariable         = [];

handles.dataOut.dataStructure = assignOptions(handles.dataStructure, handles.dataStructureDefault);

if(isnan(handles.dataOut.dataStructure.fs))
    handles.dataOut.dataStructure.fs = [];
end

guidata(hObject, handles);
close(handles.figure1);

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



function editDataVariable_Callback(hObject, eventdata, handles)
% hObject    handle to editDataVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDataVariable as text
%        str2double(get(hObject,'String')) returns contents of editDataVariable as a double
handles.dataStructure.dataVariable = get(handles.editDataVariable, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editDataVariable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDataVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editEventVariable_Callback(hObject, eventdata, handles)
% hObject    handle to editEventVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEventVariable as text
%        str2double(get(hObject,'String')) returns contents of editEventVariable as a double
handles.dataStructure.evetVariable = get(handles.editEventVariable, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editEventVariable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEventVariable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbChannAcrossRow.
function cbChannAcrossRow_Callback(hObject, eventdata, handles)
% hObject    handle to cbChannAcrossRow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbChannAcrossRow



function editFileFolderPath_Callback(hObject, eventdata, handles)
% hObject    handle to editFileFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFileFolderPath as text
%        str2double(get(hObject,'String')) returns contents of editFileFolderPath as a double
handles.dataStructure.folderName = get(handles.editDataVariable, 'String');
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function editFileFolderPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFileFolderPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbBrowse.
function pbBrowse_Callback(hObject, eventdata, handles)
% hObject    handle to pbBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
options.Interpreter = 'tex';
% Include the desired Default answer
options.Default = 'Folder';
% Use the TeX interpreter in the question
qstring = 'Open file or folder?';
choice = questdlg(qstring,'Select mat file(s)...',...
    'File','Folder',options);
if(~isempty(choice))
    if (strcmp(choice, 'File'))
        [file, folder] = uigetfile({'*.mat'});
        if(file ~= 0)
            fileFolderPath = fullfile(folder, file);
            handles.dataStructure.folderName = folder;
            handles.dataStructure.fileName = file;
            [handles.dataStructure.fileData, handles.dataStructure.variableNames]...
                = loadMatFile(fileFolderPath);
            handles.dataStructure.fileNames = {handles.dataStructure.fileName};
        end
    else
        folder = uigetdir;
        if(folder ~= 0)
            handles.dataStructure.folderName = folder;
            [handles.dataStructure.fileData,...
                handles.dataStructure.variableNames, handles.dataStructure.fileNames] = processDataFolder(handles.dataStructure.folderName);
            if(isempty(handles.dataStructure.fileData))
                msgbox('Folder does not contain any mat file(s).', 'Invalid folder');
                return;
            end
            handles.dataStructure.fileName = handles.dataStructure.fileNames{1};
        end
    end
end

set(handles.editFileFolderPath, 'String', handles.dataStructure.folderName);

guidata(hObject, handles);



% --- Executes on button press in pbSelectDataVar.
function pbSelectDataVar_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectDataVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles.dataStructure, 'variableNames'))
    return;
end
[s,v] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString', handles.dataStructure.variableNames);
if(v)
    handles.dataStructure.dataVariable = handles.dataStructure.variableNames{s};
    set(handles.editDataVariable, 'String', handles.dataStructure.dataVariable);
    if(size(handles.dataStructure.fileData.(handles.dataStructure.dataVariable), 2) > handles.MAX_CHANNELS)
        set(handles.cbChannAcrossRow, 'Value', 1);
    else
        set(handles.cbChannAcrossRow, 'Value', 0);
    end
end
guidata(hObject, handles);

% --- Executes on button press in pbSelectFs.
function pbSelectFs_Callback(hObject, ~, handles)
% hObject    handle to pbSelectFs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles.dataStructure, 'variableNames'))
    return;
end
[s,v] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString', handles.dataStructure.variableNames);
if(v)
    try
        handles.dataStructure.fsVariable        = handles.dataStructure.variableNames{s};
        handles.dataStructure.fs                = handles.dataStructure.fileData.(handles.dataStructure.fsVariable);
        if(~isscalar(handles.dataStructure.fs))
            handles.dataStructure.fsVariable    = [];
            handles.dataStructure.fs            = [];
            errordlg('Inappropriate variable for sample rate.', 'Sample Rate', 'modal');
            return;
        end
        set(handles.editSampleRate, 'String', num2str(handles.dataStructure.fs));
    catch me
        errordlg(me.message, 'Sample Rate', 'modal');
    end
end
guidata(hObject, handles);


% --- Executes on button press in pbSelectEventVar.
function pbSelectEventVar_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectEventVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles.dataStructure, 'variableNames'))
    return;
end
[s,v] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString', handles.dataStructure.variableNames);
if(v)
    handles.dataStructure.eventVariable = handles.dataStructure.variableNames{s};
    set(handles.editEventVariable, 'String', handles.dataStructure.eventVariable);
end
guidata(hObject, handles);

function [fileData, variableNames] = loadMatFile(fullPath)

fileData = load(fullPath);
variableNames = fieldnames(fileData);

function [fileData, variableNames, fileNames] = processDataFolder(folderPath)
fileNames = dir(folderPath);
fileNames = fileNames(~[fileNames(:).isdir]);
fileExtensions = regexp({fileNames(:).name}, '.*\.(.*)', 'tokens', 'once');
fileExtensions(cellfun(@isempty, fileExtensions)) = {{''}};
fileExtensions = vertcat(fileExtensions{:});
fileExtensionsValid = strcmp(fileExtensions, 'mat');
fileNames = {fileNames(fileExtensionsValid).name};

if(isempty(fileNames))
    fileData = [];
    variableNames = [];
    fileNames = [];
    return;
else
    [fileData, variableNames] = loadMatFile(fullfile(folderPath, fileNames{1}));
end
