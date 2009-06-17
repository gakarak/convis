function varargout = transporter(varargin)
% TRANSPORTER M-file for transporter.fig
%      TRANSPORTER, by itself, creates a new TRANSPORTER or raises the existing
%      singleton*.
%
%      H = TRANSPORTER returns the handle to a new TRANSPORTER or the handle to
%      the existing singleton*.
%
%      TRANSPORTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRANSPORTER.M with the given input arguments.
%
%      TRANSPORTER('Property','Value',...) creates a new TRANSPORTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before transporter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to transporter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help transporter

% Last Modified by GUIDE v2.5 30-Oct-2008 16:17:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @transporter_OpeningFcn, ...
                   'gui_OutputFcn',  @transporter_OutputFcn, ...
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


% --- Executes just before transporter is made visible.
function transporter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to transporter (see VARARGIN)

% Choose default command line output for transporter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes transporter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = transporter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isvalid(handles.ttimer)
    stop(handles.ttimer);
    delete(handles.ttimer);
end
close


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% % handles.ttimer = timer('TimerFcn',@timer_callback,'Period',2,'ExecutionMode','fixedDelay');
clc

txtr=imread('textures/rocks/img045.jpg');
tr_w = size(txtr);
txtb=imread('textures/rocks/img047.jpg');
tb_w = size(txtb);
st_r_size.width = 3*tr_w(2);
st_r_size.height = 400;

handles.t_length  = st_r_size.width;
handles.t_width   = st_r_size.height;
handles.t_height  = st_r_size.height;

%%%%%%%%%% BEGIN INIT SECTION %%%%%%%%%%%%%%%%%
handles.style = 'Random'
handles.drnd = 5;
handles.idrnd = 1;

handles.dpx = 3;
handles.fps = 15;

%%% random
% handles.random_amin = ceil(2*handles.t_height/5);
handles.random_amax = ceil(2*handles.t_height/5);
handles.random_dv = 3;
handles.random_ddv = 1;

%%% sine
handles.sine_a0 = ceil(2*handles.t_height/5);
handles.sine_amp = ceil(2*handles.t_height/5);
handles.sine_t = ceil(handles.t_width);
handles.sine_pos = 0;

%%% mask array
handles.mask_array = zeros(handles.t_width,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


handles.ttimer = timer('TimerFcn',@timer_callback,...
    'Period',1/handles.fps,'StartDelay',0.2,'ExecutionMode','fixedDelay',...
    'UserData',[hObject]);



Thalf = maketform('affine',[1 0; 0 1; 0 0]);
R = makeresampler({'cubic','nearest'},'circular');
handles.full_r = imtransform(txtr,Thalf,R,'XData',[1 st_r_size.width],...
    'YData',[1 st_r_size.height],'FillValues',[0 0 0]');
handles.full_b = imtransform(txtb,Thalf,R,'XData',[1 st_r_size.width],...
    'YData',[1 st_r_size.height],'FillValues',[0 0 0]');

handles.full_r = double(rgb2gray(handles.full_r));
handles.full_b = double(rgb2gray(handles.full_b));

handles.curr_pos = 1;
handles.dpx = 2;

handles.cut_r = handles.full_r(1:handles.t_height,1:handles.t_width);
handles.cut_b = handles.full_b(1:handles.t_height,1:handles.t_width);

handles.mask = zeros(handles.t_height,handles.t_width);


guidata(hObject, handles)


function timer_callback(obj, evdata, handls)
hObj = get(obj,'UserData');
handles = guidata(hObj);

time_curr = toc;
time_delta = time_curr - handles.time_old;
handles.time_old = time_curr;

% % if (handles.curr_pos+handles.t_width) > handles.t_length
% %     handles.curr_pos = handles.curr_pos+handles.t_width - handles.t_length;
% % end

% % set(hObj,'CurrentAxes',handles.dra);
% figure(handles.output);


% % cut_r = handles.full_r(1:handles.t_height,...
% %     handles.curr_pos:handles.curr_pos+handles.t_width-1);
% % cut_b = handles.full_b(1:handles.t_height,...
% %     handles.curr_pos:handles.curr_pos+handles.t_width-1);


handles.cut_r = circshift(handles.cut_r,[0 -handles.dpx]);
handles.cut_b = circshift(handles.cut_b,[0 -handles.dpx]);

cut_r = handles.cut_r;
cut_b = handles.cut_b;

cut_r = cut_r.*handles.mask;
cut_b = cut_b.*(~handles.mask);
cut = cut_r + cut_b;


mask = circshift(handles.mask,[0 -handles.dpx]);

switch handles.style
    case 'Random'
        len_line_mask = ceil(handles.t_height/4) + ceil(rand()*handles.t_height/10);
        line_mask = zeros(handles.t_height, handles.dpx);
        line_mask(ceil(handles.t_height/2) - len_line_mask:ceil(handles.t_height/2) + len_line_mask,:) = 1;
    case 'PhaseSine'
    case 'UnPhaseSine'
    case 'Constant'
        len_line_mask = ceil(handles.t_height/4);
        line_mask = zeros(handles.t_height, handles.dpx);
        line_mask(ceil(handles.t_height/2) - len_line_mask:ceil(handles.t_height/2) + len_line_mask,:) = 1;
end

mask(:,1:handles.dpx) = line_mask;
handles.mask = mask;



set(handles.h_img,'CData',uint8(cut));

if handles.is_check_load
    handles.load_arr = circshift(handles.load_arr,-handles.dpx);
    load=2*len_line_mask/handles.t_height;
    handles.load_arr(handles.siz_load_arr-handles.dpx+1:handles.siz_load_arr)=load;
    set(handles.load_plot,'YData',handles.load_arr);
    set(handles.textLoad,'String',['Load: ',num2str(100*load),' [%]'])
end

if handles.is_check_dist
    handles.dist_arr = circshift(handles.dist_arr,-1);
    handles.dist_arr(handles.siz_dist_arr)=handles.dist_arr(handles.siz_dist_arr-1) + handles.dpx;
    set(handles.dist_plot,'YData',handles.dist_arr);
    set(handles.textDist,'String',['Distance: ',num2str(handles.dist_arr(handles.siz_dist_arr)),' [px]']);
end

if handles.is_check_vel
    handles.vel_arr = circshift(handles.vel_arr,-1);
    handles.vel_arr(handles.siz_vel_arr)=handles.dpx/time_delta;
    set(handles.vel_plot,'YData',handles.vel_arr);
    set(handles.textVel,'String',['Velocity: ',num2str(handles.vel_arr(handles.siz_vel_arr)),' [px/s]']);
end

% % handles.curr_pos = handles.curr_pos + handles.dpx;
% % axes(handles.drawarea);
guidata(hObj, handles);
% % disp(handles.dpx);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.time_old=0;
tic;
start(handles.ttimer);
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.ttimer);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function drawarea_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drawarea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% % image(handles.full_r(1:300,1:300,:));
% % handles.dra = handles.drawarea;
% % guidata(hObject, handles);
handles.drawarea=hObject;
handles.h_img = image(zeros(handles.t_height,handles.t_width));
colormap(gray(255));
guidata(hObject, handles);
% Hint: place code in OpeningFcn to populate drawarea


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% % axes(handles.drawarea);
set(handles.h_img,'CData',handles.full_r(1:handles.t_height,...
    handles.curr_pos:handles.curr_pos+handles.t_width));
% % colormap(gray(255));


% --- Executes on slider movement.
function sliderDPX_Callback(hObject, eventdata, handles)
% hObject    handle to sliderDPX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dpx = ceil(1 + get(hObject,'Value'));
set(handles.textValDPX,'String',[num2str(handles.dpx),' dpx']);
guidata(hObject,handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderDPX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderDPX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',20);
set(hObject,'SliderStep',[0.05 0.1]);
handles.dpx = 3;
set(hObject,'Value',handles.dpx);
guidata(hObject,handles);




% --- Executes on slider movement.
function sliderFPS_Callback(hObject, eventdata, handles)
% hObject    handle to sliderFPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.fps = ceil(1 + get(hObject,'Value'));
set(handles.textValFPS,'String',[num2str(handles.fps),' fps']);
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliderFPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderFPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',100);
set(hObject,'SliderStep',[0.05 0.1]);
handles.fps = 10;
set(hObject,'Value',handles.fps);
guidata(hObject,handles);



% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
% % switch get(eventdata.NewValue,'String')
% %     case 'Random'
% %         handles.style = 
% %     otherwise
% %         disp('Unknown')
% % end
handles.style = get(eventdata.NewValue,'String');
handles.style
guidata(hObject,handles);



% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.ttimer);
set(handles.ttimer,'Period',1/handles.fps);
start(handles.ttimer);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function textValFPS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textValFPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',[num2str(handles.fps),' fps']);


% --- Executes during object creation, after setting all properties.
function textValDPX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textValDPX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',[num2str(handles.dpx),' dpx']);


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function radiobutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Enable','on');


% --- Executes during object creation, after setting all properties.
function distPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.siz_dist_arr=100;
handles.dist_arr = zeros(handles.siz_dist_arr,1);
handles.dist_plot = plot(handles.dist_arr);
guidata(hObject,handles);

% Hint: place code in OpeningFcn to populate distPlot


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
to_list = timerfind;
for ii=1:length(to_list)
    disp(['Delete timer [',to_list(ii).Name,'] ...']);
    delete(to_list(ii));
end


% --- Executes on button press in checkDist.
function checkDist_Callback(hObject, eventdata, handles)
% hObject    handle to checkDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.is_check_dist = true;
else
    handles.is_check_dist = false;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkDist


% --- Executes on button press in checkVel.
function checkVel_Callback(hObject, eventdata, handles)
% hObject    handle to checkVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.is_check_vel = true;
else
    handles.is_check_vel = false;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkVel


% --- Executes during object creation, after setting all properties.
function velPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to velPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.siz_vel_arr=100;
handles.vel_arr = zeros(handles.siz_vel_arr,1);
handles.vel_plot = plot(handles.vel_arr);
guidata(hObject,handles);
% Hint: place code in OpeningFcn to populate velPlot


% --- Executes during object creation, after setting all properties.
function checkDist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkDist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);
handles.is_check_dist = false;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function checkVel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkVel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);
handles.is_check_vel = false;
guidata(hObject,handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.h_img,'CData',handles.full_b(1:handles.t_height,...
    handles.curr_pos:handles.curr_pos+handles.t_width));


% --- Executes on button press in checkLoad.
function checkLoad_Callback(hObject, eventdata, handles)
% hObject    handle to checkLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    handles.is_check_load=true;
else
    handles.is_check_load=false;
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of checkLoad


% --- Executes during object creation, after setting all properties.
function checkLoad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);
handles.is_check_load = false;
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function loadPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.siz_load_arr=100;
handles.load_arr = zeros(handles.siz_load_arr,1);
handles.load_plot=plot(handles.load_arr);
guidata(hObject,handles);
% Hint: place code in OpeningFcn to populate loadPlot


% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.style = get(hObject,'String');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton4


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.style = get(hObject,'String');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton2


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.style = get(hObject,'String');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.style = get(hObject,'String');
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of radiobutton3


