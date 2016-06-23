function varargout = gMatchedFilter(varargin)
% GMATCHEDFILTER MATLAB code for gMatchedFilter.fig
%      GMATCHEDFILTER, by itself, creates a new GMATCHEDFILTER or raises the existing
%      singleton*.
%
%      H = GMATCHEDFILTER returns the handle to a new GMATCHEDFILTER or the handle to
%      the existing singleton*.
%
%      GMATCHEDFILTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GMATCHEDFILTER.M with the given input arguments.
%
%      GMATCHEDFILTER('Property','Value',...) creates a new GMATCHEDFILTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gMatchedFilter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gMatchedFilter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gMatchedFilter

% Last Modified by GUIDE v2.5 15-Mar-2016 12:32:43

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
                   'gui_OpeningFcn', @gMatchedFilter_OpeningFcn, ...
                   'gui_OutputFcn',  @gMatchedFilter_OutputFcn, ...
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


% --- Executes just before gMatchedFilter is made visible.
function gMatchedFilter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gMatchedFilter (see VARARGIN)

% Choose default command line output for gMatchedFilter
handles.output = hObject;

dataIn = varargin{1};

handles.dataSet1 = dataIn.('dataSet');
handles.channels = dataIn.('channels');

handles.subjectNum = handles.dataSet1.subjectNum;
handles.sessionNum = handles.dataSet1.sessionNum;
handles.trialTime = handles.dataSet1.epochTime;
handles.dataRate = handles.dataSet1.dataRate;

%Default values
handles.centreChannel = handles.channels(1);
handles.templateStart = 0;
handles.templateEnd = handles.trialTime;
handles.roiStart = 0;
handles.roiEnd = handles.trialTime;
handles.cueTime = 0.25;
handles.step = 200;
handles.T = 0.5;
handles.ncws = 2;

handles.extrials = 0;
handles.verbose = 0;
handles.cueNoncue = 1;

handles.trainpc = 50;
handles.validpc = 0;
handles.testpc = 50;

handles.Ti = 0;
handles.Ts = 0.1;
handles.Tf = 1;

% Update centre channels pop up menu
txtChannels = cellstr(num2str(handles.channels'))';
set(handles.pumCentreChannel, 'String', txtChannels);
set(handles.pumCentreChannel, 'Value', 1);


%Startup data selection

lst = handles.dataSet1.listSessions;
handles.sessionNum = lst(1);
set(handles.pum_session, 'String', num2str(lst));
set(handles.pum_session, 'Value', 1);

lst = handles.dataSet1.listSubjects;
handles.subjectNum = lst(1);
set(handles.pum_subject, 'String', num2str(lst));
set(handles.pum_subject, 'Value', 1);

set(handles.editChannels, 'String', num2str(handles.channels));

% Default parameters
set(handles.editTemplateStart, 'String', num2str(handles.templateStart));
set(handles.editTemplateEnd, 'String', num2str(handles.templateEnd));
set(handles.editROIStart, 'String', num2str(handles.roiStart));
set(handles.editROIEnd, 'String', num2str(handles.roiEnd));

% Update Controls
set(handles.pb_validate, 'Enable', 'Off');
set(handles.pb_test, 'Enable', 'Off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gMatchedFilter wait for user response (see UIRESUME)
%uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gMatchedFilter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%delete(hObject);


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
%P = normc(P);

fOrder = 2;
fLow = 1;
[bl,al] = butter(fOrder,fLow*2/handles.dataRate,'low');

%Repetition samples are added to the signal. The number of samples depend on the
%order of the filter.
padSamples = 64;
P = [P(1:padSamples,:); P(:,:)];

P = filter(bl,al, P);
P = P(padSamples+1:end,:);
processedData = eegOperations.shapeSst(P, nT);

filterCoffs = -1 .* ones(1, length(handles.channels)) ./ (length(handles.channels) - 1);
filterCoffs(handles.centreChannel) = 1;
processedData = spatialFilterSstData(processedData, filterCoffs');

[ handles.X, handles.Xcv, handles.Xtest]...
    = eegData.splitDataMF(processedData, [handles.templateStart handles.templateEnd],...
    [handles.roiStart handles.roiEnd], handles.dataRate,  handles.trainpc,...
    handles.validpc, handles.testpc );

%Training
handles.model = mean(handles.X, 3);

figure
t= handles.templateStart + 1/handles.dataRate:1/handles.dataRate:handles.templateEnd;
plot(t, handles.model, 'lineWidth', 3);
xlabel('Time(s)')
ylabel('Amplitude')
title(sprintf('Template created from %d trials', size(handles.X, 3)));

if(handles.cueNoncue)
    hold
    a = axis;
    line([handles.cueTime handles.cueTime], [a(3) a(4)], 'LineStyle','-', 'Color', 'red', 'LineWidth', 2);
    axis(a);
end


minModel = min(handles.model);

minTime = t(handles.model(:) == minModel);
msgbox(strcat(sprintf('Training Complete.\n\nTraining trials: %d\nValidation trials: %d\nTest Trials: %d\nPeak Neg. at: %.3f\n',...
    size(handles.X, 3), size(handles.Xcv, 3), size(handles.Xtest, 3), minTime)),'Training results');
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

[filteredData, timeVect] = matchedFilterSstData(handles.model .* 2, handles.Xtest,...
    handles.step, handles.dataRate, 0, [handles.roiStart handles.roiEnd]);

tRange = handles.Ti:handles.Ts:handles.Tf;

validateData = zeros(length(tRange), 3);

for i=1:length(tRange)
    threshData = (filteredData > tRange(i)) .* 1;
    [~, validateData(i,1), validateData(i,2), validateData(i,3)] = processEvents(threshData, timeVect, handles.ncws, handles.cueTime);
end

figure
plot(tRange(:), validateData(:,1), 'o', 'color', 'blue')
xlabel('T')
ylabel('Time (s)')
title('Average delay')
figure
plot(tRange(:), validateData(:,2), 'o', 'color', 'blue')
xlabel('T')
ylabel('Percentage')
title('True positive rate')
figure
plot(tRange(:), validateData(:,3), 'o', 'color', 'blue')
xlabel('T')
ylabel('Percentage')
title('False positive rate')




% --- Executes on button press in pb_test.
function pb_test_Callback(hObject, eventdata, handles)
% hObject    handle to pb_test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Matched Filtering
[filteredData, timeVect] = matchedFilterSstData(handles.model .* 2, handles.Xtest,...
    handles.step, handles.dataRate, handles.verbose, [handles.roiStart handles.roiEnd]);

%Thresholding
threshData = (filteredData > handles.T) .* 1;
if(handles.verbose)
    eegData.plotSstData({timeVect}, {threshData}, {'Threshold Result'}, {'STEM'}, -1);
end

[eventData, averageDelay, tpr, fpr] = processEvents(threshData, timeVect, handles.ncws, handles.cueTime);
eegData.plotSstData({timeVect}, {eventData}, {'Events'}, {'STEM'}, -1);

msgbox(sprintf('True positive rate: %.1f\nFalse negative rate: %.1f\nAverage detection delay: %.1f',tpr, fpr, averageDelay),'Test results');


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
set(handles.pb_validate, 'Enable', 'Off');
set(handles.pb_test, 'Enable', 'Off');
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
set(handles.pb_validate, 'Enable', 'Off');
set(handles.pb_test, 'Enable', 'Off');
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



function editT_Callback(hObject, eventdata, handles)
% hObject    handle to editT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editT as text
%        str2double(get(hObject,'String')) returns contents of editT as a double
val = get(hObject,'String');
T = str2double(val);
if(~isnan(T))
    if(T < 0 || T > 1)
        errordlg('T cannot be less than 0 or greater than 1.','Threshold selection', 'modal');
        set(hObject, 'String', handles.T);
    else
        handles.T = T;
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function editT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTemplateStart_Callback(hObject, eventdata, handles)
% hObject    handle to editTemplateStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTemplateStart as text
%        str2double(get(hObject,'String')) returns contents of editTemplateStart as a double
val = get(hObject,'String');
templateStart = str2double(val);
if(~isnan(templateStart))
    if(templateStart >=handles.templateEnd || templateStart < 0 || templateStart > handles.trialTime)
        errordlg('Invalid template start time. The start time should be greater than zero and less than trial time and template end time.',...
            'Template selection', 'modal');
        set(hObject, 'String', num2str(handles.templateStart));
    else
        handles.templateStart = templateStart;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function editTemplateStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTemplateStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTemplateEnd_Callback(hObject, eventdata, handles)
% hObject    handle to editTemplateEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTemplateEnd as text
%        str2double(get(hObject,'String')) returns contents of editTemplateEnd as a double
val = get(hObject,'String');
templateEnd = str2double(val);
if(~isnan(templateEnd))
    if(templateEnd <= handles.templateStart || templateEnd > handles.trialTime)
        errordlg('Invalid template end time. The end time should be greater than template start time and less than trial time.',...
            'Template selection', 'modal');
        set(hObject, 'String', num2str(handles.templateEnd));
    else
        handles.templateEnd = templateEnd;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function editTemplateEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTemplateEnd (see GCBO)
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

function editStep_Callback(hObject, eventdata, handles)
% hObject    handle to editStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStep as text
%        str2double(get(hObject,'String')) returns contents of editStep as a double
val = get(hObject,'String');
step = str2double(val);
if(~isnan(step))
    if(~(rem(step,1) == 0) || step<=ceil(1000/handles.dataRate))
        errordlg(sprintf('Step must be integer and greater than %d ms.', ceil(1000/handles.dataRate)),'Step selection', 'modal');
        set(hObject, 'String', handles.step);
    else
        handles.step = step;
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function editStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStep (see GCBO)
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
handles.verbose = val;
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



function editTi_Callback(hObject, eventdata, handles)
% hObject    handle to editTi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTi as text
%        str2double(get(hObject,'String')) returns contents of editTi as a double
val = get(hObject,'String');
Ti = str2double(val);
if(~isnan(Ti))
    if(Ti < 0 || Ti >= handles.Tf)
        errordlg(sprintf('The value should be greater than or equal to 0 and less than %d.',...
            handles.Tf), 'Range selection', 'modal');
        set(hObject, 'String', handles.Ti);
    else
        handles.Ti = Ti;
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function editTi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTs_Callback(hObject, eventdata, handles)
% hObject    handle to editTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTs as text
%        str2double(get(hObject,'String')) returns contents of editTs as a double
val = get(hObject,'String');
Ts = str2double(val);
if(~isnan(Ts))
    if(Ts >= handles.Tf)
        errordlg(sprintf('The value should smaller than Tf:%d.',...
            handles.Tf), 'Range selection', 'modal');
        set(hObject, 'String', handles.Ts);
    else
        handles.Ts = Ts;
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function editTs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTf_Callback(hObject, eventdata, handles)
% hObject    handle to editTf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTf as text
%        str2double(get(hObject,'String')) returns contents of editTf as a double
val = get(hObject,'String');
Tf = str2double(val);
if(~isnan(Tf))
    if(Tf <= handles.Ti || Tf > 1)
        errordlg(sprintf('The value should be greater than Ti: %d and less than or equal to 1.', handles.Ti),...
            'Range selection', 'modal');
        set(hObject, 'String', handles.Tf);
    else
        handles.Tf = Tf;
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function editTf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTf (see GCBO)
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
% if isequal(get(hObject, 'waitstatus'), 'waiting')
%     uiresume(hObject);
% else
%     delete(hObject);
% end
delete(hObject);



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
        txtChannels = cellstr(num2str(channels'))';
        set(handles.pumCentreChannel, 'String', txtChannels);
        set(handles.pumCentreChannel, 'Value', 1);
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
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
    
    txtChannels = cellstr(num2str(channels'))';
        set(handles.pumCentreChannel, 'String', txtChannels);
        set(handles.pumCentreChannel, 'Value', 1);
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        
    guidata(hObject, handles);
end


% --- Executes on selection change in pumCentreChannel.
function pumCentreChannel_Callback(hObject, eventdata, handles)
% hObject    handle to pumCentreChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pumCentreChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pumCentreChannel
val = get(hObject,'Value');
handles.centreChannel = val;
set(handles.pb_validate, 'Enable', 'Off');
set(handles.pb_test, 'Enable', 'Off');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pumCentreChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pumCentreChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNCWs_Callback(hObject, eventdata, handles)
% hObject    handle to editNCWs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNCWs as text
%        str2double(get(hObject,'String')) returns contents of editNCWs as a double
val = get(hObject,'String');
ncws = str2double(val);
if(~isnan(ncws))
    if(~(rem(ncws,1) == 0) || ncws<=0)
        errordlg('Invalid NCWs. This value should be a non zero integer.','NCWs selection', 'modal');
        set(hObject, 'String', num2str(handles.ncws));
    else
        handles.ncws = ncws;
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function editNCWs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNCWs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editROIStart_Callback(hObject, eventdata, handles)
% hObject    handle to editROIStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editROIStart as text
%        str2double(get(hObject,'String')) returns contents of editROIStart as a double
val = get(hObject,'String');
roiStart = str2double(val);
if(~isnan(roiStart))
    if(roiStart >=handles.roiEnd || roiStart < 0 || roiStart > handles.trialTime)
        errordlg('Invalid start time. The start time should be greater than zero and less than trial time and end time.',...
            'ROI selection', 'modal');
        set(hObject, 'String', num2str(handles.roiStart));
    else
        handles.roiStart = roiStart;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function editROIStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editROIStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editROIEnd_Callback(hObject, eventdata, handles)
% hObject    handle to editROIEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editROIEnd as text
%        str2double(get(hObject,'String')) returns contents of editROIEnd as a double
val = get(hObject,'String');
roiEnd = str2double(val);
if(~isnan(roiEnd))
    if(roiEnd <= handles.roiStart || roiEnd > handles.trialTime)
        errordlg('Invalid end time. The end time should be greater than start time and less than trial time.',...
            'ROI selection', 'modal');
        set(hObject, 'String', num2str(handles.roiEnd));
    else
        handles.roiEnd = roiEnd;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end


% --- Executes during object creation, after setting all properties.
function editROIEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editROIEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbCueNoncue.
function cbCueNoncue_Callback(hObject, eventdata, handles)
% hObject    handle to cbCueNoncue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbCueNoncue
val = get(hObject,'Value');
handles.cueNoncue = val;
set(handles.pb_validate, 'Enable', 'Off');
set(handles.pb_test, 'Enable', 'Off');
if(val)
    set(handles.editCueTime, 'Enable', 'On');
else
    set(handles.editCueTime, 'Enable', 'Off');
end
guidata(hObject, handles);


function editCueTime_Callback(hObject, eventdata, handles)
% hObject    handle to editCueTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCueTime as text
%        str2double(get(hObject,'String')) returns contents of editCueTime as a double
val = get(hObject,'String');
cueTime = str2double(val);
if(~isnan(cueTime))
    if(cueTime > handles.trialTime || cueTime <= 0)
        errordlg('Invalid cue Time. This value should be between 0 and trial time.','Cue time selection', 'modal');
        set(hObject, 'String', num2str(handles.cueTime));
    else
        handles.cueTime = cueTime;
        set(handles.pb_validate, 'Enable', 'Off');
        set(handles.pb_test, 'Enable', 'Off');
        guidata(hObject, handles);
    end
end

% --- Executes during object creation, after setting all properties.
function editCueTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCueTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [eventData, averageDelay, tpr, fpr] = processEvents(threshData, timeVect, ncws, cueTime)

%Generating events
eventData = zeros(size(threshData));
eventDelay = zeros(2, size(threshData, 3));
truePositives = 0;
falsePositives = 0;
for i = 1:size(threshData, 3)
    shiftReg = zeros(1, ncws);
    tpCounted = 0;
    for j = 1:size(threshData, 1)
        shiftReg(ncws) = threshData(j,:,i);
        if(sum(shiftReg) == ncws)
            eventData(j,:,i) = 1;
            if(timeVect(j) >= cueTime)
                if(tpCounted)
                    falsePositives = falsePositives + 1;
                else
                    truePositives = truePositives + 1;
                    eventDelay(1,j) = timeVect(j) - cueTime;
                    eventDelay(2,j) = j;
                end
                tpCounted = 1;
            else
                falsePositives = falsePositives + 1;
            end
        end
        shiftReg = circshift(shiftReg, [1, -1]);
        shiftReg(ncws) = 0;
    end
end

tpr = truePositives/size(eventData, 3) * 100;
fpr = falsePositives/size(eventData, 3) * 100;

averageDelay = sum(eventDelay(1,eventDelay(2,:) ~= 0))/sum(eventDelay(2,:) ~= 0);
