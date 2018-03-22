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
%
% Edit the above text to modify the response to help importOptionsDlg
%
% Last Modified by GUIDE v2.5 30-Jan-2018 13:58:10
%
%
% Copyright (c) <2016> <Usman Rashid>
% Licensed under the MIT License. See License.txt in the project root for 
% license information.

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
handles.ffData = [];

% Update handles structure
guidata(hObject, handles);

% View setup
heightRatio = 0.4;
widthRatio = 0.4;
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
handles.ffData.fs = str2double(get(handles.editSampleRate, 'String'));
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
handles.dataStructureDefault.eventVariable      = [];
handles.dataStructureDefault.channelsAcrossRows = get(handles.cbChannAcrossRow, 'Value');
handles.dataStructureDefault.fileNames          = [];
handles.dataStructureDefault.fileName           = [];     % Name of the loaded file
handles.dataStructureDefault.fileData           = [];
handles.dataStructureDefault.folderName         = [];
handles.dataStructureDefault.fsVariable         = [];
handles.dataStructureDefault.fileNum            = 1;
handles.dataStructureDefault.channelNamesVariable = [];
    

handles.dataOut.ffData = assignOptions(handles.ffData, handles.dataStructureDefault);

if(isempty(handles.dataOut.ffData.folderName))
    errordlg('Inappropriate data folder.', 'Data Folder', 'modal');
    return;
end

if(isempty(handles.dataOut.ffData.dataVariable))
    errordlg('Inappropriate data variable.', 'Data Variable', 'modal');
    return;
end

if(isnan(handles.dataOut.ffData.fs) || isempty(handles.dataOut.ffData.fs))
    errordlg('Inappropriate value for sample rate.', 'Sample Rate', 'modal');
    return;
end

% Computed variables
handles.dataOut.ffData.numFiles = length(handles.dataOut.ffData.fileNames);

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
handles.ffData.dataVariable = get(handles.editDataVariable, 'String');
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
handles.ffData.folderName = get(handles.editDataVariable, 'String');
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
            handles.ffData.folderName = folder;
            handles.ffData.fileName = file;
            [handles.ffData.fileData, handles.ffData.variableNames]...
                = loadMatFile(fileFolderPath);
            handles.ffData.fileNames = {handles.ffData.fileName};
            set(handles.editFileFolderPath, 'String', handles.ffData.folderName);
        end
    else
        folder = uigetdir;
        if(folder ~= 0)
            handles.ffData.folderName = folder;
            [handles.ffData.fileData,...
                handles.ffData.variableNames, handles.ffData.fileNames] = processDataFolder(handles.ffData.folderName);
            if(isempty(handles.ffData.fileData))
                msgbox('Folder does not contain any mat file(s).', 'Invalid folder');
                return;
            end
            handles.ffData.fileName = handles.ffData.fileNames{1};
            set(handles.editFileFolderPath, 'String', handles.ffData.folderName);
        end
    end
end

guidata(hObject, handles);



% --- Executes on button press in pbSelectDataVar.
function pbSelectDataVar_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectDataVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles.ffData, 'variableNames'))
    return;
end
[s,v] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString', handles.ffData.variableNames);
if(v)
    handles.ffData.dataVariable = handles.ffData.variableNames{s};
    set(handles.editDataVariable, 'String', handles.ffData.dataVariable);
    if(size(handles.ffData.fileData.(handles.ffData.dataVariable), 2) > handles.MAX_CHANNELS)
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
if(~isfield(handles.ffData, 'variableNames'))
    return;
end
[s,v] = listdlg('PromptString','Select a variable:',...
    'SelectionMode','single',...
    'ListString', handles.ffData.variableNames);
if(v)
    try
        handles.ffData.fsVariable        = handles.ffData.variableNames{s};
        handles.ffData.fs                = handles.ffData.fileData.(handles.ffData.fsVariable);
        if(~isscalar(handles.ffData.fs))
            handles.ffData.fsVariable    = [];
            handles.ffData.fs            = [];
            errordlg('Inappropriate variable for sample rate.', 'Sample Rate', 'modal');
            return;
        end
        set(handles.editSampleRate, 'String', num2str(handles.ffData.fs));
    catch me
        errordlg(me.message, 'Sample Rate', 'modal');
    end
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
