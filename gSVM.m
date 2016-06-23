function varargout = gSVM(varargin)
% GSVM MATLAB code for gSVM.fig
%      GSVM, by itself, creates a new GSVM or raises the existing
%      singleton*.
%
%      H = GSVM returns the handle to a new GSVM or the handle to
%      the existing singleton*.
%
%      GSVM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GSVM.M with the given input arguments.
%
%      GSVM('Property','Value',...) creates a new GSVM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gSVM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gSVM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gSVM

% Last Modified by GUIDE v2.5 09-Mar-2016 14:47:20

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
                   'gui_OpeningFcn', @gSVM_OpeningFcn, ...
                   'gui_OutputFcn',  @gSVM_OutputFcn, ...
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


% --- Executes just before gSVM is made visible.
function gSVM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gSVM (see VARARGIN)

% Choose default command line output for gSVM
handles.output = hObject;

dataIn = varargin{1};

handles.dataSet1 = dataIn.('dataSet');
handles.channels = dataIn.('channels');

handles.subjectNum = handles.dataSet1.subjectNum;
handles.sessionNum = handles.dataSet1.sessionNum;
handles.trialTime = handles.dataSet1.epochTime;
handles.dataRate = handles.dataSet1.dataRate;

%Default values
handles.intvl1a = 0;
handles.intvl2a = 0.5;
handles.intvl1b = 0.5;
handles.intvl2b = 1;
handles.extrials = 1;
handles.C = 100;
handles.trainpc = 50;
handles.validpc = 0;
handles.testpc = 50;
handles.passes = 20;
handles.showPlots = 0;
handles.Ci = 1;
handles.Cs = 10;
handles.Cf = 100;


%Startup data selection
set(handles.pum_session, 'String', num2str(handles.dataSet1.listSessions));
set(handles.pum_session, 'Value', handles.sessionNum);

set(handles.pum_subject, 'String', num2str(handles.dataSet1.listSubjects));
set(handles.pum_subject, 'Value', handles.subjectNum);


set(handles.editChannels, 'String', num2str(handles.channels));

% Update Controls
set(handles.pb_validate, 'Enable', 'Off');
set(handles.pb_test, 'Enable', 'Off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gSVM wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gSVM_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject);


% --- Executes on button press in pb_train.
function pb_train_Callback(hObject, eventdata, handles)
% hObject    handle to pb_train (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.extrials)
    exepochs = ~handles.dataSet1.extrials;
else
    exepochs = ones(1, length(handles.dataSet1.extrials));
    exepochs = exepochs == 1;
end
processingData = handles.dataSet1.sstData(:, handles.channels, exepochs);
[P, nT] = eegOperations.shapeProcessing(processingData);
P = detrend(P, 'constant');
P = normc(P);

[bl,al] = butter(2,1*2/handles.dataRate,'low');

%Repetition samples are added to the signal. The number of samples depend on the
%order of the filter.
padSamples = 64;
P = [P(1:padSamples,:); P(:,:)];

P = filter(bl,al, P);
P = P(padSamples+1:end,:);
processedData = eegOperations.shapeSst(P, nT);

[ handles.X, handles.Xcv, handles.Xtest, handles.y, handles.ycv, handles.ytest]...
    = eegData.splitData(processedData, [handles.intvl1a handles.intvl2a],...
    [handles.intvl1b handles.intvl2b], handles.dataRate,  handles.trainpc,...
    handles.validpc, handles.testpc );

%Training
handles.model = svmTrain(handles.X, handles.y, handles.C, @linearKernel, 1e-3,...
    handles.passes);
handles.pred = svmPredict(handles.model, handles.X);
msgbox(strcat('Training Set Accuracy:', sprintf(' %f',...
    mean(double(handles.pred == handles.y)) * 100)),'Training results');
if(handles.validpc ==0)
    set(handles.pb_test, 'Enable', 'On');
    set(handles.pb_validate, 'Enable', 'Off');
else
    set(handles.pb_validate, 'Enable', 'On');
    set(handles.pb_test, 'Enable', 'On');
end
guidata(hObject, handles);


% --- Executes on button press in pb_validate.
function pb_validate_Callback(hObject, eventdata, handles)
% hObject    handle to pb_validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cRange = handles.Ci:handles.Cs:handles.Cf;

accur = zeros(length(cRange), 2);

for i=1:length(cRange)
    model = svmTrain(handles.X, handles.y, cRange(i), @linearKernel, 1e-3, handles.passes);
    pred = svmPredict(model, handles.X);
    predCv = svmPredict(model, handles.Xcv);
    
    accur(i,1) = mean(double(pred == handles.y)) * 100;
    accur(i,2) = mean(double(predCv == handles.ycv)) * 100;
end

figure
plot(cRange(:), accur(:,1), 'o', 'color', 'red')
xlabel('C')
ylabel('Accuracy')
hold
plot(cRange(:), accur(:,2), '*', 'color', 'blue')
title('Validation Curve')
legend('Training data', 'Validation data')




% --- Executes on button press in pb_test.
function pb_test_Callback(hObject, eventdata, handles)
% hObject    handle to pb_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
predTest = svmPredict(handles.model, handles.Xtest);
if(handles.showPlots)
    figure
    plot(handles.y, 'o', 'color', 'red')
    xlabel('Sample Number')
    ylabel('Class Label')
    hold
    plot(handles.pred, '*', 'color', 'blue')
    title('Prediction for Training Data')
    legend('Ground Truth', 'Prediction')
    
    figure
    plot(handles.ytest, 'o', 'color', 'red')
    xlabel('Sample Number')
    ylabel('Class Label')
    hold
    plot(predTest, '*', 'color', 'blue')
    title('Prediction for Test Data')
    legend('Ground Truth', 'Prediction')
end
msgbox({strcat('Training Set Accuracy:', sprintf(' %f',...
    mean(double(handles.pred == handles.y)) * 100)) '' strcat('Test Set Accuracy:',...
    sprintf(' %f', mean(double(predTest == handles.ytest)) * 100))},'Test results');


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

handles.dataSet1.loadData(handles.subjectNum, handles.sessionNum);
guidata(hObject, handles);

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


% --- Executes on selection change in pum_subject.
function pum_subject_Callback(hObject, eventdata, handles)
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

handles.dataSet1.loadData(handles.subjectNum, handles.sessionNum);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pum_subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pum_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_extrials.
function cb_extrials_Callback(hObject, eventdata, handles)
% hObject    handle to cb_extrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_extrials
val = get(hObject,'Value');
handles.extrials = val;
set(handles.pb_validate, 'Enable', 'Off');
set(handles.pb_test, 'Enable', 'Off');
guidata(hObject, handles);


% --- Executes on button press in cb_allsessions.
function cb_allsessions_Callback(hObject, eventdata, handles)
% hObject    handle to cb_allsessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_allsessions



function edit_C_Callback(hObject, eventdata, handles)
% hObject    handle to edit_C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_C as text
%        str2double(get(hObject,'String')) returns contents of edit_C as a double
val = get(hObject,'String');
C = str2num(val);
if(~isnan(C))
    if(C < 0)
        errordlg('C cannot be less than 0.','Parameter selection', 'modal');
        set(hObject, 'String', handles.C);
    else
        handles.C = C;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_C_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_C (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_intvl1a_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intvl1a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intvl1a as text
%        str2double(get(hObject,'String')) returns contents of edit_intvl1a as a double
val = get(hObject,'String');
intvl1a = str2num(val);
if(~isnan(intvl1a))
    if(intvl1a >=handles.intvl2a || intvl1a < 0 || intvl1a > handles.trialTime)
        errordlg('Invalid interval.','Interval selection', 'modal');
        set(hObject, 'String', num2str(handles.intvl1a));
    else
        handles.intvl1a = intvl1a;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_intvl1a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intvl1a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_intvl2a_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intvl2a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intvl2a as text
%        str2double(get(hObject,'String')) returns contents of edit_intvl2a as a double
val = get(hObject,'String');
intvl2a = str2num(val);
if(~isnan(intvl2a))
    if(intvl2a <= handles.intvl1a || intvl2a < 0 || intvl2a > handles.trialTime)
        errordlg('Invalid interval.','Interval selection', 'modal');
        set(hObject, 'String', num2str(handles.intvl2a));
    else
        handles.intvl2a = intvl2a;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_intvl2a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intvl2a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_intvl1b_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intvl1b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intvl1b as text
%        str2double(get(hObject,'String')) returns contents of edit_intvl1b as a double
val = get(hObject,'String');
intvl1b = str2num(val);
if(~isnan(intvl1b))
    if(intvl1b >=handles.intvl2b || intvl1b < 0 || intvl1b > handles.trialTime)
        errordlg('Invalid interval.','Interval selection', 'modal');
        set(hObject, 'String', num2str(handles.intvl1b));
    else
        handles.intvl1b = intvl1b;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_intvl1b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intvl1b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_intvl2b_Callback(hObject, eventdata, handles)
% hObject    handle to edit_intvl2b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_intvl2b as text
%        str2double(get(hObject,'String')) returns contents of edit_intvl2b as a double
val = get(hObject,'String');
intvl2b = str2num(val);
if(~isnan(intvl2b))
    if(intvl2b <= handles.intvl1b || intvl2b < 0 || intvl2b > handles.trialTime)
        errordlg('Invalid interval.','Interval selection', 'modal');
        set(hObject, 'String', num2str(handles.intvl2b));
    else
        handles.intvl2b = intvl2b;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_intvl2b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_intvl2b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_trainpc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trainpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trainpc as text
%        str2double(get(hObject,'String')) returns contents of edit_trainpc as a double
val = get(hObject,'String');
trainpc = str2num(val);
if(~isnan(trainpc))
    if(trainpc < 0 || trainpc > 100)
        errordlg('The value should be from 0 to 100','Percentage selection', 'modal');
        set(hObject, 'String', handles.trainpc);
    else
        handles.trainpc = trainpc;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_trainpc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trainpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_validationpc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_validationpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_validationpc as text
%        str2double(get(hObject,'String')) returns contents of edit_validationpc as a double
val = get(hObject,'String');
validpc = str2num(val);
if(~isnan(validpc))
    if(validpc < 0 || validpc > 100)
        errordlg('The value should be from 0 to 100','Percentage selection', 'modal');
        set(hObject, 'String', handles.validpc);
    else
        handles.validpc = validpc;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_validationpc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_validationpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_testpc_Callback(hObject, eventdata, handles)
% hObject    handle to edit_testpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_testpc as text
%        str2double(get(hObject,'String')) returns contents of edit_testpc as a double
val = get(hObject,'String');
testpc = str2num(val);
if(~isnan(testpc))
    if(testpc < 0 || testpc > 100)
        errordlg('The value should be from 0 to 100','Percentage selection', 'modal');
        set(hObject, 'String', handles.testpc);
    else
        handles.testpc = testpc;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_testpc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_testpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_passes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_passes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_passes as text
%        str2double(get(hObject,'String')) returns contents of edit_passes as a double
val = get(hObject,'String');
passes = str2num(val);
if(~isnan(passes))
    if(passes < 0)
        errordlg('Passes cannot be less than 0.','Parameter selection', 'modal');
        set(hObject, 'String', handles.passes);
    else
        handles.passes = passes;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function edit_passes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_passes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cb_plots.
function cb_plots_Callback(hObject, eventdata, handles)
% hObject    handle to cb_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_plots
val = get(hObject,'Value');
handles.showPlots = val;
guidata(hObject, handles);


% --- Executes on selection change in pum_channel.
function pum_channel_Callback(hObject, eventdata, handles)
% hObject    handle to pum_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pum_channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pum_channel
val = get(hObject,'Value');
if(val > handles.tochannel)
    errordlg('Invalid channel number.','Channel selection','modal');
    set(hObject, 'Value', handles.channelNum);
else
    handles.channelNum = val;
    set(handles.pb_validate, 'Enable', 'Off');
    set(handles.pb_test, 'Enable', 'Off');
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function pum_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pum_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pum_tochannel.
function pum_tochannel_Callback(hObject, eventdata, handles)
% hObject    handle to pum_tochannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pum_tochannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pum_tochannel
val = get(hObject,'Value');
if(val < handles.channelNum)
    errordlg('Invalid channel number.','Channel selection', 'modal');
    set(hObject, 'Value', handles.tochannel);
else
    handles.tochannel = val;
    set(handles.pb_validate, 'Enable', 'Off');
    set(handles.pb_test, 'Enable', 'Off');
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function pum_tochannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pum_tochannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_ncData.
function pb_ncData_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ncData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit_Ci_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Ci (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Ci as text
%        str2double(get(hObject,'String')) returns contents of edit_Ci as a double
val = get(hObject,'String');
Ci = str2num(val);
if(~isnan(Ci))
    if(Ci <= 0 || Ci >= handles.Cf)
        errordlg(sprintf('The value should be greater than 0 and less than %d.',...
            handles.Cf), 'Range selection', 'modal');
        set(hObject, 'String', handles.Ci);
    else
        handles.Ci = Ci;
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_Ci_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Ci (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Cs_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Cs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Cs as text
%        str2double(get(hObject,'String')) returns contents of edit_Cs as a double
val = get(hObject,'String');
Cs = str2num(val);
if(~isnan(Cs))
    if(Cs >= handles.Cf)
        errordlg(sprintf('The value should smaller than Cf:%d.',...
            handles.Cf), 'Range selection', 'modal');
        set(hObject, 'String', handles.Cs);
    else
        handles.Cs = Cs;
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_Cs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Cs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Cf_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Cf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Cf as text
%        str2double(get(hObject,'String')) returns contents of edit_Cf as a double
val = get(hObject,'String');
Cf = str2num(val);
if(~isnan(Cf))
    if(Cf <= handles.Ci)
        errordlg(sprintf('The value should be greater than Ci: %d.', handles.Ci),...
            'Range selection', 'modal');
        set(hObject, 'String', handles.Cf);
    else
        handles.Cf = Cf;
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function edit_Cf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Cf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
        guidata(hObject, handles);
    else
        errordlg('Wrong channel(s) selected.','Channel selection', 'modal');
    end
end

% --- Executes during object creation, after setting all properties.
function editChannels_CreateFcn(hObject, eventdata, handles)
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
channelsInfo = {num2str(handles.dataSet1.listChannels), handles.dataSet1.listChannelNames};
[channels,~] = listdlg('PromptString','Select channels:',...
                'ListString',channelsInfo{1,2});
if(~isempty(channels))
    
    channelNames = channelsInfo{1,2}(channels,:);
    handles.channels = channels;
    set(handles.editChannels,'String', sprintf('%s ', channelNames{:}));
    guidata(hObject, handles);
end
