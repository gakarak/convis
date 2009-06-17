function varargout = testwebcam(varargin)
% TESTWEBCAM M-file for testwebcam.fig
%      TESTWEBCAM, by itself, creates a new TESTWEBCAM or raises the existing
%      singleton*.
%
%      H = TESTWEBCAM returns the handle to a new TESTWEBCAM or the handle to
%      the existing singleton*.
%
%      TESTWEBCAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTWEBCAM.M with the given input arguments.
%
%      TESTWEBCAM('Property','Value',...) creates a new TESTWEBCAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testwebcam_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testwebcam_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testwebcam

% Last Modified by GUIDE v2.5 05-Oct-2008 10:21:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testwebcam_OpeningFcn, ...
                   'gui_OutputFcn',  @testwebcam_OutputFcn, ...
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


% --- Executes just before testwebcam is made visible.
function testwebcam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testwebcam (see VARARGIN)

% Choose default command line output for testwebcam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testwebcam wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testwebcam_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonClose.
function buttonClose_Callback(hObject, eventdata, handles)
% hObject    handle to buttonClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.ttimer);
delete(handles.ttimer);
stop(handles.init_timer);
delete(handles.init_timer);
close


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
clc
handles.count = 0;

% % handles.vid_bf_siz = zeros(1,4);
% % handles.vid_sf_siz = zeros(1,4);
guidata(hObject, handles);

%%%%%%%
function fcn_timer(obj,evd,dd)
hobj = get(obj,'UserData');
handles = guidata(hobj);
meminfo = imaqmem;
mem_free = ['free: ',num2str((meminfo.FrameMemoryLimit-meminfo.FrameMemoryUsed)/(1024*1024)),'Mb'];
mem_total = [' tot: ',num2str(meminfo.FrameMemoryLimit/(1024*1024)),'Mb '];
mem_load = ['load: ',num2str(meminfo.MemoryLoad),'%'];

set(handles.textMemory,'String',...
    {mem_free, mem_total, mem_load});

function fcn_init_timer(obj,evd,dd)
    hObject = get(obj,'UserData');
    handles = guidata(hObject);
    [hObject, handles] = prep_frame(hObject, handles);
    draw_frames(hObject, handles);
    guidata(hObject, handles);
disp('start');


%%%%%%%

% --- Executes on selection change in listAdaptors.
function listAdaptors_Callback(hObject, eventdata, handles)
% hObject    handle to listAdaptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cnt = get(hObject,'String');
cnt{get(hObject, 'Value')};
set_id(hObject,handles);
set_formats(hObject,handles);

% Hints: contents = get(hObject,'String') returns listAdaptors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listAdaptors


% --- Executes during object creation, after setting all properties.
function listAdaptors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listAdaptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Enable','off');


% --- Executes on button press in buttonRefreshImaq.
function buttonRefreshImaq_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRefreshImaq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Enable','Off');
imaqreset
set(hObject,'Enable','On');


% --- Executes on selection change in listId.
function listId_Callback(hObject, eventdata, handles)
% hObject    handle to listId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_formats(hObject,handles);
% Hints: contents = get(hObject,'String') returns listId contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listId


% --- Executes during object creation, after setting all properties.
function listId_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Enable','off');


% --- Executes on button press in buttonFind.
function buttonFind_Callback(hObject, eventdata, handles)
% hObject    handle to buttonFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_adaptor(hObject,handles);
set_id(hObject,handles);
set_formats(hObject,handles);



% --- Executes on button press in buttonTest.
function buttonTest_Callback(hObject, eventdata, handles)
% hObject    handle to buttonTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'String',['count: ',num2str(handles.count)]);
handles.count = handles.count + 1;
guidata(hObject,handles);
% % get(handles.listAdaptors,'String')


% --- Executes on selection change in listFormats.
function listFormats_Callback(hObject, eventdata, handles)
% hObject    handle to listFormats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cont = get(hObject,'String');
cont{get(hObject,'Value')};
% Hints: contents = get(hObject,'String') returns listFormats contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listFormats


% --- Executes during object creation, after setting all properties.
function listFormats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listFormats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Enable','off');

%%%%%%%%%%%%%%%%%%%
function set_adaptor(hObject,handles)
imi = imaqhwinfo();
if isempty(imi.InstalledAdaptors)
    set(handles.listAdaptors,'Enable','off');
    
else
    set(handles.listAdaptors,'String',imi.InstalledAdaptors);
    set(handles.listAdaptors,'Enable','on');
end

function set_id(hObject,handles)
ads_all = get(handles.listAdaptors,'String');
ads_sel = ads_all{get(handles.listAdaptors,'Value')};

imi = imaqhwinfo(ads_sel);
imi_ids = imi.DeviceIDs;
lst_id = {};
for ii=1:length(imi_ids)
    lst_id = [lst_id, imi_ids{ii}];
end
if isempty(lst_id)
    lst_id = {'not found'};
    set(handles.listId,'Enable','off');
else
    set(handles.listId,'Enable','on');
end
set(handles.listId,'String',lst_id);
set(handles.listId,'Value',1);


function set_formats(hObject, handles)
cnt_adp = get(handles.listAdaptors,'String');
adp = cnt_adp{get(handles.listAdaptors,'Value')};

cnt_id = get(handles.listId,'String');
id = cnt_id{get(handles.listId,'Value')};

lst_fmt = {};
cam_name = 'Cam: ';
try
    imi = imaqhwinfo(adp, str2num(id));
    cam_name = [cam_name,imi.DeviceName];
    for ii=1:length(imi.SupportedFormats)
        lst_fmt = [lst_fmt, imi.SupportedFormats{ii}];
    end
catch ee
    disp(['Error: can''t get cam videoformats ...  ']);
end

if isempty(lst_fmt)
    lst_fmt = {'not found'};
    cam_name = [cam_name,'Unknown'];
    set(handles.listFormats,'Enable','off');
else
    set(handles.listFormats,'Enable','on');
end
set(handles.listFormats,'Value',1);
set(handles.panelParams,'Title',cam_name);
set(handles.listFormats,'String',lst_fmt);

function [adp,id,fmt] = get_adp_id_fmt(hObject,handles)
    cnt_adp = get(handles.listAdaptors,'String');
    cnt_id = get(handles.listId,'String');
    cnt_fmt = get(handles.listFormats,'String');

    adp = cnt_adp{get(handles.listAdaptors,'Value')};
    id = cnt_id{get(handles.listId,'Value')};
    fmt = cnt_fmt{get(handles.listFormats,'Value')};

function res = check_cam(hObject, handles)
if strcmp(get(handles.listAdaptors,'Enable'),'on')...
        && strcmp(get(handles.listId,'Enable'),'on')...
        && strcmp(get(handles.listFormats,'Enable'),'on')
    res = true;
    return;
else
    res = false;
    return;
end


function fcn_start(obj,event)
    disp('start');

function fcn_stop(obj,event)
    hobj = get(obj,'UserData');
    handles = guidata(hobj);
    set(handles.buttonStop,'Enable','off');
    set(handles.buttonStart,'Enable','on');

    disp('Stop');
    flushdata(obj);
    delete(obj);
    clear obj;

function fcn_trigger(obj,event)
disp('Trigger')

function fcn_acquire(obj,event)
    hobj = get(obj,'UserData');
    handles = guidata(hobj);
% %     frm = peekdata(obj,1);
    frm = getdata(obj,1);
%%% histeq
% %     frm(:,:,1) = histeq(frm(:,:,1));
% %     frm(:,:,2) = histeq(frm(:,:,2));
% %     frm(:,:,3) = histeq(frm(:,:,3));

%%% imadjust
    frm(:,:,1) = imadjust(frm(:,:,1));
    frm(:,:,2) = imadjust(frm(:,:,2));
    frm(:,:,3) = imadjust(frm(:,:,3));

%%% adapthisteq
% %     frm(:,:,1) = adapthisteq(frm(:,:,1));
% %     frm(:,:,2) = adapthisteq(frm(:,:,2));
% %     frm(:,:,3) = adapthisteq(frm(:,:,3));

    set(handles.axes_img,'CData',frm);


function draw_frames(obj,handl)
    set(handl.vid_big_frame,'Position',handl.vid_bf_siz);
    set(handl.vid_small_frame,'Position',handl.vid_sf_siz);
    
function create_frame(obj,handl)
    axes(handl.axesXak);
    handl.vid_big_frame = rectangle('Position',handl.vid_bf_siz,...
        'LineStyle','--');
% %     ,...
% %         'HandleVisibility ','callback');
    handl.vid_small_frame = rectangle('Position',handl.vid_sf_siz,...
        'EdgeColor','red');
% %     ,...
% %         'HandleVisibility ','callback');
    guidata(obj,handl);
    
function [ret_hObject, ret_handles] = prep_frame(hObject, handles)
    handles.vid_bf_width = 1+ceil(0.9*get(handles.sliderBFWidth,'Value')*handles.vid_res(1));
    handles.vid_bf_height = 1+ceil(0.9*get(handles.sliderBFHeight,'Value')*handles.vid_res(2));
    handles.vid_sf_width = 1+ceil(0.5*get(handles.sliderSFWidth,'Value')*handles.vid_res(1));
    handles.vid_sf_height = 1+ceil(0.5*get(handles.sliderSFHeight,'Value')*handles.vid_res(2));
    %%%
    set(handles.textBFHeight,'String',['[',num2str(handles.vid_bf_height),']']);
    handles.vid_bf_siz(2) = ceil((handles.vid_res(2)-handles.vid_bf_height)/2);
    handles.vid_bf_siz(4) = handles.vid_bf_height;
    %%%
    set(handles.textSFHeight,'String',['[',num2str(handles.vid_sf_height),']']);
    handles.vid_sf_siz(2) = ceil((handles.vid_res(2)-handles.vid_sf_height)/2);
    handles.vid_sf_siz(4) = handles.vid_sf_height;
    %%%
    set(handles.textBFWidth,'String',['[',num2str(handles.vid_bf_width),']']);
    handles.vid_bf_siz(1) = ceil((handles.vid_res(1)-handles.vid_bf_width)/2);
    handles.vid_bf_siz(3) = handles.vid_bf_width;
    %%%
    set(handles.textSFWidth,'String',['[',num2str(handles.vid_sf_width),']']);
    handles.vid_sf_siz(1) = ceil((handles.vid_res(1)-handles.vid_sf_width)/2);
    handles.vid_sf_siz(3) = handles.vid_sf_width;

    ret_hObject = hObject;
    ret_handles = handles;
% % guidata(hObject, handles);
% % pause(0.1);
%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in buttonPreview.
function buttonPreview_Callback(hObject, eventdata, handles)
% hObject    handle to buttonPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[adp, id, fmt] = get_adp_id_fmt(hObject, handles);

% % if strcmp(get(handles.listAdaptors,'Enable'),'on')...
% %         && strcmp(get(handles.listId,'Enable'),'on')...
% %         && strcmp(get(handles.listFormats,'Enable'),'on')
if check_cam(hObject, handles)
    handles.vidObj = videoinput(adp,str2num(id),fmt);
    preview(handles.vidObj);
    guidata(hObject, handles);
    set(handles.buttonStopPreview,'Enable','on');
    set(handles.buttonPreview,'Enable','off');
end

% --- Executes on button press in buttonStopPreview.
function buttonStopPreview_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStopPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closepreview(handles.vidObj);
delete(handles.vidObj);
set(handles.buttonStopPreview,'Enable','off');
set(handles.buttonPreview,'Enable','on');

% --- Executes during object creation, after setting all properties.
function buttonStopPreview_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonStopPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');


% --- Executes on button press in buttonStart.
function buttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[adp, id, fmt] = get_adp_id_fmt(hObject, handles);

if check_cam(hObject, handles)
    handles.vid = videoinput(adp,str2num(id),fmt);
    set(handles.vid,'ReturnedColorSpace','rgb');
    set(handles.vid,'UserData',[hObject]);
    set(handles.vid,'FramesAcquiredFcnCount',1);
    set(handles.vid,'FramesPerTrigger',Inf);
    %%%
    set(handles.vid,'StartFcn',@fcn_start);
    set(handles.vid,'FramesAcquiredFcn',@fcn_acquire);
    set(handles.vid,'TriggerFcn',@fcn_trigger);
    set(handles.vid,'StopFcn',@fcn_stop);
    %%%
    handles.vid_res = get(handles.vid,'VideoResolution');
    guidata(hObject, handles);
% %     set(getselectedsource(handles.vid),'BrightnessMode','auto');
% %     set(getselectedsource(handles.vid),'BacklightCompensation','on');
% %     get(getselectedsource(handles.vid))
    
    axes(handles.axesXak);
    handles.axes_img = image(rand(handles.vid_res(2), handles.vid_res(1)));
    set(handles.axes_img,'Clipping','off');
    
% %     axes(handles.axesXak);
% %     handles.axes_img = image(rand(handles.vid_res));
    
%%%% BEGIN refresh resolution data
% % % %     delete(handles.vid_big_frame);
% % % %     clear handles.vid_big_frame;
% % % %     delete(handles.vid_small_frame);
% % % %     clear handles.vid_small_frame;

% %     create_frame(hObject, handles);
    [hObject, handles] = prep_frame(hObject, handles);
    handles.vid_big_frame = rectangle('Position',handles.vid_bf_siz,...
        'LineStyle','--');
    handles.vid_small_frame = rectangle('Position',handles.vid_sf_siz,...
        'EdgeColor','red');
% %     draw_frames(hObject,handles);
    
%%%% END
    set(handles.buttonStop,'Enable','on');
    set(handles.buttonStart,'Enable','off');
    start(handles.vid);
    guidata(hObject, handles);
end



% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.vid);
% % set(handles.buttonStop,'Enable','off');
% % set(handles.buttonStart,'Enable','on');

% --- Executes during object creation, after setting all properties.
function buttonStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','off');


% --- Executes during object creation, after setting all properties.
function axesOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Tag','axesOut');
handles.axesXak = hObject;
handles.axes_img = image(rand(100,100));
% % get(handles.axes_img);
handles.vid_res = [100 100];

handles.vid_bf_siz = [1, 1, handles.vid_res(1)-1, handles.vid_res(2)-1];
handles.vid_sf_siz = [1, 1, handles.vid_res(1)-1, handles.vid_res(2)-1];
% % create_frame(hObject, handles);
handles.vid_big_frame = rectangle('Position',handles.vid_bf_siz,...
    'LineStyle','--',...
    'HandleVisibility ','callback');
handles.vid_small_frame = rectangle('Position',handles.vid_sf_siz,...
    'EdgeColor','red',...
    'HandleVisibility ','callback');

handles.init_timer = timer('TimerFcn',@fcn_init_timer,...
    'Period',3,...
    'ExecutionMode','singleShot',...
    'UserData',[hObject],...
    'StartDelay',1);
start(handles.init_timer);

guidata(hObject, handles);
% Hint: place code in OpeningFcn to populate axesOut


% --- Executes on button press in buttonMemClean.
function buttonMemClean_Callback(hObject, eventdata, handles)
% hObject    handle to buttonMemClean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
lst_imaq_obj = imaqfind('Type','videoinput');

for ii=1:length(lst_imaq_obj)
    flushdata(lst_imaq_obj{ii});
    delete(lst_imaq_obj{ii});
    clear lst_imaq_obj{ii};
end


% --- Executes during object creation, after setting all properties.
function textMemory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textMemory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% % 'StartFcn',@fcn_start_timer,...
handles.ttimer = timer('TimerFcn',@fcn_timer,...
    'Period',3,...
    'ExecutionMode','fixedDelay',...
    'UserData',[hObject],...
    'StartDelay',2);
start(handles.ttimer);
guidata(hObject,handles);


% --- Executes on slider movement.
function sliderBFWidth_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBFWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bfw = 1+ceil(0.9*handles.vid_res(1)*get(hObject,'Value'));
sfw = handles.vid_sf_width;

if (sfw+4) < bfw
    handles.vid_bf_width = 1+ceil(0.9*handles.vid_res(1)*get(hObject,'Value'));
    set(handles.textBFWidth,'String',['[',num2str(handles.vid_bf_width),']']);

    handles.vid_bf_siz(1) = ceil((handles.vid_res(1)-handles.vid_bf_width)/2);
    handles.vid_bf_siz(3) = handles.vid_bf_width;
    guidata(hObject,handles);
    %!
    draw_frames(hObject,handles);
else
    disp('Error: width of innner frame bigger than width of outer frame.');
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderBFWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBFWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0.6);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderSFHeight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSFHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bfh = handles.vid_bf_height;
sfh = 1+ceil(0.5*handles.vid_res(2)*get(hObject,'Value'));

if ((sfh+4) < bfh)
    handles.vid_sf_height = 1+ceil(0.5*handles.vid_res(2)*get(hObject,'Value'));
    set(handles.textSFHeight,'String',['[',num2str(handles.vid_sf_height),']']);
    handles.vid_sf_siz(2) = ceil((handles.vid_res(2)-handles.vid_sf_height)/2);
    handles.vid_sf_siz(4) = handles.vid_sf_height;
    guidata(hObject,handles);
    %!
    draw_frames(hObject,handles);
else
    disp('Error: height of innner frame bigger than height of outer frame.');
end
    % Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderSFHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSFHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0.2);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderSFWidth_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSFWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bfw = handles.vid_bf_width;
sfw = 1+ceil(0.5*handles.vid_res(1)*get(hObject,'Value'));

if (sfw + 4) < bfw 
    handles.vid_sf_width = 1+ceil(0.5*handles.vid_res(1)*get(hObject,'Value'));
    set(handles.textSFWidth,'String',['[',num2str(handles.vid_sf_width),']']);
    handles.vid_sf_siz(1) = ceil((handles.vid_res(1)-handles.vid_sf_width)/2);
    handles.vid_sf_siz(3) = handles.vid_sf_width;
    guidata(hObject,handles);
    %!
    draw_frames(hObject,handles);
else
    disp('Error: width of innner frame bigger than width of outer frame.');
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderSFWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSFWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0.2);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderBFHeight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBFHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bfh = 1+ceil(0.9*handles.vid_res(2)*get(hObject,'Value'));
sfh = handles.vid_sf_height;

if (sfh+4) < bfh
    handles.vid_bf_height = 1+ceil(0.9*handles.vid_res(2)*get(hObject,'Value'));
    set(handles.textBFHeight,'String',['[',num2str(handles.vid_bf_height),']']);
    handles.vid_bf_siz(2) = ceil((handles.vid_res(2)-handles.vid_bf_height)/2);
    handles.vid_bf_siz(4) = handles.vid_bf_height;
    guidata(hObject,handles);
    %!
    draw_frames(hObject,handles);
else
    disp('Error: height of innner frame bigger than height of outer frame.');
end
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderBFHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBFHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0.6);
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% % % pause(0.2);
% % % prep_frame(hObject, handles);
% % % draw_frames(hObject,handles);
disp('resize');


% --- Executes on button press in buttonRedraw.
function buttonRedraw_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRedraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles] = prep_frame(hObject,handles);
% % prep_frame(hObject,handles);
draw_frames(hObject,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function textSFWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSFWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function textBFWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBFWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function textBFHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textBFHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function textSFHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textSFHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listAdaptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listAdaptors.
function listAdaptors_Callback(hObject, eventdata, handles)
% hObject    handle to listAdaptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listAdaptors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listAdaptors


% --- Executes on selection change in listId.
function listId_Callback(hObject, eventdata, handles)
% hObject    handle to listId (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listId contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listId


% --- Executes during object creation, after setting all properties.
function buttonRefreshImaq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonRefreshImaq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function buttonFind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function buttonMemClean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonMemClean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function buttonTest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function panelParams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panelParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


