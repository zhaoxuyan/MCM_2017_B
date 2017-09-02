function varargout = MMc(varargin)
% MMC M-file for MMc.fig
%      MMC, by itself, creates a new MMC or raises the existing
%      singleton*.
%	
%      copy of xuwentao
%
%      H = MMC returns the handle to a new MMC or the handle to
%      the existing singleton*.
%
%      MMC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MMC.M with the given input arguments.
%
%      MMC('Property','Value',...) creates a new MMC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MMc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MMc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MMc

% Last Modified by GUIDE v2.5 03-Nov-2010 23:20:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MMc_OpeningFcn, ...
    'gui_OutputFcn',  @MMc_OutputFcn, ...
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


% --- Executes just before MMc is made visible.
function MMc_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MMc (see VARARGIN)

% Choose default command line output for MMc
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MMc wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MMc_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function num_server_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to num_server_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_server_EDIT as text
%        str2double(get(hObject,'String')) returns contents of num_server_EDIT as a double


% --- Executes during object creation, after setting all properties.
function num_server_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_server_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num_serverTemp= str2double(get(handles.num_server_EDIT,'String'))  ;

ST_Idle=0;%%%服务台为空闲
ST_Busy=1;%%%服务台为繁忙
ST_All_Busy=-1;%%%所有服务台为繁忙
EV_NULL=0;
EV_Arrive=1;
EV_Depart=2;
EV_LEN=3;
Q_LIMIT=str2double(get(handles.Q_LIMIT_EDIT,'String'))  ;                %%%%%%%%%%排队系统容量
Q_LIMIT=1e10;

time_arrival=[];                 %到达时刻
time_next_event=zeros(1,EV_LEN);
%仿真参数
num_events=EV_LEN-1;
num_serveCounter=num_serverTemp;                  %%%%M/M/m  m为服务台数量
mean_interarrival=str2double(get(handles.mean_interarrival_EDIT,'String'))  ;      %%%%%顾客平均到达间隔时间
mean_service=str2double(get(handles.mean_service_EDIT,'String'))  ;             %%%%%为顾客服务平均服务时间
num_peo_required=str2double(get(handles.num_delays_required_EDIT,'String'))  ;           %%%%%%%顾客来源总量

serv_time=zeros(1,num_peo_required);
outfile=fopen('MMc.txt','w');
fprintf(outfile, 'MMc多服务台排队仿真系统：\r\n');
fprintf(outfile, '平均到达间隔时间为%11.3f minutes\r\n',mean_interarrival);
fprintf(outfile, '平均服务时间为%16.3f minutes\r\n', mean_service);
fprintf(outfile, '服务台数为%20d\r\n', num_serveCounter);
fprintf(outfile, '顾客总数为%14d\r\n', num_peo_required);

%part1 初始化
sim_time=0.0;
server_status   =zeros(1,num_serveCounter);   %状态空闲
num_in_q        = 0;%队列人数
time_last_event = 0.0;%事件持续时间
num_custs_simulated  = 0;%%%已经完成仿真的顾客数量
total_of_delays    = 0.0;%%%%%%队列中顾客等待总的时间
total_of_time    = 0.0;%%%%%%系统中顾客逗留总时间
area_num_in_q      = 0.0;
area_server_status = 0.0;

%/* Initialize event list. 初始事件表，因为没有顾客到达接受服务，离开事件时刻初始为无穷大*/
time_next_event(EV_Arrive) = sim_time + exprnd(mean_interarrival);%%记录时间事件表下一到达事件时间
time_next_event(EV_Depart) = 1.0e+230;%%记录时间事件表下一离开事件时间

time_serveDepart=zeros(1,num_serveCounter);%%%记录每个服务台实体中的顾客，服务完毕后离开此服务台的时刻
ordinal_serveCounter_depart=0;
    
%part2  
while (num_custs_simulated < num_peo_required)
%/*决定下次发生什么事件 */
min_time_next_event = 1.0e+290;
%  找出time_serveDepart(1,:)最小值所对应的下标i赋给ordinal_serveCounter_depart，确定当前时刻第几个服务台中的顾客最先离开
min_time_serveDepart=1e290;
ordinal_serveCounter_depart=0;
for i=1:num_serveCounter%%%%%%% 也可用[val,pos]=min(time_serveDepart)代替，得出val和pos
    if(server_status(i)==1 && time_serveDepart(i)<min_time_serveDepart)
        min_time_serveDepart=time_serveDepart(i);
        ordinal_serveCounter_depart=i;
    end
end
time_next_event(2)=min_time_serveDepart;

%/* 确定下一最早发生事件的类型： 1代表Arrive，2代表Departure */ 
next_event_type = 0;
for i = 1: num_events
    if (time_next_event(i) < min_time_next_event)
        min_time_next_event = time_next_event(i);
        next_event_type     = i;
    end
end

%/* 事件列表是否为空. */
if (next_event_type == 0)
    % 空事件表，终止仿真
    fprintf(outfile, '\r\nEvent list empty at time %f', sim_time);
    exit(1);
end
%/* 事件表不空，推进仿真时钟到下一最早时刻*/
sim_time = min_time_next_event;
double time_since_last_event; %%%刚发生事件持续时间
time_since_last_event = sim_time - time_last_event;
time_last_event       = sim_time;
%/* 更新队列中的（人数*排队时间），为了计算平均队列长即队列中的平均顾客数/
area_num_in_q=area_num_in_q +  num_in_q * time_since_last_event;
%/* 为了计算平均队长即系统中的平均顾客数 */
for i=1:num_serveCounter
    area_server_status =area_server_status + server_status(i) * time_since_last_event;
end

%/* Invoke the appropriate event function. */
%arrival
if(next_event_type==EV_Arrive)
    double delay;  
    %/* 找出第ordinal_serveCounter个服务台是空闲ST_Idle；并且按照号由小到大排序，找到小号服务台空闲break*/
    ordinal_serveCounter=ST_All_Busy;
    for i=1:num_serveCounter
        if (server_status(i) == ST_Idle)
            ordinal_serveCounter=i;
            break;
        end
    end
    %/* 所有服务台忙，队长加1. */
    if(ordinal_serveCounter==ST_All_Busy)
        num_in_q=1+num_in_q;
        %/* check队列容量是否已满 */
        if (num_in_q > Q_LIMIT)
            %/* 超出队列容量，终止仿真. */
            fprintf(outfile, '\r\nOverflow of the array time_arrival at');
            fprintf(outfile, ' time %f', sim_time);
            exit(2);
        end
        %/* 队列容量非满仍有空间, 储存即将到达顾客的时刻于队列末尾. */
        time_arrival(length(time_arrival)+1)=sim_time;
    else      
%/* num_custs_simulated加1，置服务台忙. */
        num_custs_simulated = 1 + num_custs_simulated;
        server_status(ordinal_serveCounter) = ST_Busy;
        %/* 产生此顾客离开时刻. */
        serv_time(num_custs_simulated)=exprnd(mean_service);
        time_serveDepart(ordinal_serveCounter) = sim_time + serv_time(num_custs_simulated);
    end
      %/* Schedule 下次到达事件. */
  time_next_event(1) = sim_time + exprnd(mean_interarrival);
    
else%(next_event_type==EV_Depart)
    double delay;
    %/* check队列是否为空. */
    if (num_in_q == 0)
        % /*置刚刚顾客离开的服务台为空闲*/
        server_status(ordinal_serveCounter_depart)      = ST_Idle;
        time_serveDepart(ordinal_serveCounter_depart) = 1.0e+230;
    else
        %/* 队列非空，队列长减去1. */
        num_in_q=num_in_q-1;        
        %/*计算此名顾客排队等待时间，更新总排队等待时间. */        
        delay = sim_time - time_arrival(1);
        total_of_delays =total_of_delays + delay;  %%%%%total_of_delays所有人排队总时间        
        %/* 进入仿真系统得到服务的人数加1, 产生此顾客离开时刻 */        
        num_custs_simulated = 1 + num_custs_simulated;
        serv_time(num_custs_simulated)=exprnd(mean_service);%mean_service
        time_serveDepart(ordinal_serveCounter_depart) = sim_time + serv_time(num_custs_simulated);    
        
        %/*队列中的顾客向前移位，第二名到队首，依次前移…… */
        tempForPop=time_arrival(2:length(time_arrival));
        time_arrival=tempForPop;
    end %if (num_in_q == 0)
end %if(next_event_type==EV_Arrive)
end %while


%%%%%%%%%% part 3
%/*输出Little公式计算结果*/
fprintf(outfile, '\r\nLittle公式计算结果： \r\n');
rou=mean_service/mean_interarrival/num_serveCounter;%%%%%%%%%%服务台利用率即服务强度有Little公式直接计算得到。
fprintf(outfile, '系统利用率rou=mean_service/mean_interarrival/num_serveCounter %8.3f \r\n',rou);
%%%%%%%%%%%%%%%%%%%---------------以下为单列多服务台Little计算公式。---------
Lambda=1/mean_interarrival;
u=1/mean_service ;
A=Lambda/u;
sum=0;
c=num_serveCounter;
for k=0:c-1
    sum=sum+(A^k)/factorial(k);
end
P0=( sum+(A^c)/ factorial(c)/(1-rou) )^(-1);
Lq=((c*rou)^c)*rou*P0/( factorial(c)*(1-rou)^2 ) ;    Wq=Lq/Lambda;
Ls=Lq+Lambda/u;      Ws=Ls/Lambda;

%%%%%%%%%%%%%%%%%%%---------------此为单列单服务台Little计算公式。---------
%     Ws=1/(u-Lambda);%%Little公式直接计算得到系统中顾客平均逗留时间
%     Ls=Lambda*Ws;%%Little公式直接计算得到队长即系统中的平均顾客数
%     Wq=rou/(u-Lambda);%%Little公式直接计算得到队列中顾客平均等待时间
%     Lq=Lambda*Wq;%%Little公式直接计算得到排队队列长即队列中的平均顾客数
%     fprintf(outfile, 'Wq=rou/(u-Lambda);%%Little公式直接计算得到队列中顾客平均等待时间 %11.3f \r\n',Wq);
%     fprintf(outfile, 'Ws=1/(u-Lambda);%%Little公式直接计算得到系统中顾客平均逗留时间 %11.3f \r\n',Ws);
%      fprintf(outfile, '  Lq=Lambda*Wq;%%Little公式直接计算得到排队队列长即队列中的平均顾客数 %11.3f \r\n',Lq);
%      fprintf(outfile, ' Ls=Lambda*Ws;%%Little公式直接计算得到队长即系统中的平均顾客数 %11.3f \r\n',Ls);
%   %%%%%%%%%%%%%%------------------------此为单列单服务台Little计算公式。---------

fprintf(outfile, '整个系统空闲的概率 P0 %11.3f \r\n',P0);
fprintf(outfile, '队列中顾客平均等待时间 Wq %11.3f \r\n',Wq);
fprintf(outfile, '系统中顾客平均逗留时间Ws %11.3f \r\n',Ws);
fprintf(outfile, '排队队列长即队列中的平均顾客数Lq %11.3f \r\n',Lq);
fprintf(outfile, '队长即 系统 中的平均顾客数Ls  %11.3f%\r\n\r\n',Ls);

%/* 输出仿真结果 */
 sum_serv_time=0;
for i=1:num_peo_required
    sum_serv_time=sum_serv_time+serv_time(i);
end
total_of_time =total_of_delays +sum_serv_time; %%%%%total_of_time所有人排队加服务的总时间
delay_in_queue=total_of_delays / num_custs_simulated;
delay_in_system=total_of_time / num_custs_simulated;
number_in_queue=area_num_in_q / sim_time;
number_in_serve=area_server_status / sim_time;
number_in_system=number_in_queue+number_in_serve;
server_utilization=area_server_status / sim_time/num_serveCounter;

fprintf(outfile, '\r\n\r\n仿真结果：\r\n');
fprintf(outfile, '系统利用率%15.3f\r\n',server_utilization );  %%%%%%%%%%服务台利用率即服务强度有仿真得到。
fprintf(outfile, '队列中顾客平均等待时间Wq %11.3f minutes\r\n',delay_in_queue);
fprintf(outfile, '系统中顾客平均逗留时间 Ws%11.3f minutes\r\n',delay_in_system);
fprintf(outfile, '队列长即队列中的平均顾客数Lq%11.3f\r\n',number_in_queue);
fprintf(outfile, '队长即系统中的平均顾客数Ls%11.3f\r\n',number_in_system);
fprintf(outfile, '系统的仿真时间%15.3f minutes', sim_time);
fclose(outfile);
set(handles.rou_TEXT,'String', num2str(rou));

set(handles.delay_in_queue_TEXT,'String', num2str(delay_in_queue));
set(handles.delay_in_system_TEXT,'String',num2str(delay_in_system));
set(handles.number_in_queue_TEXT,'String',num2str(number_in_queue));
set(handles.server_utilization_TEXT,'String',num2str(server_utilization));
set(handles.sim_time_TEXT,'String',num2str(sim_time));
guidata(hObject, handles);


function mean_interarrival_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to mean_interarrival_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mean_interarrival_EDIT as text
%        str2double(get(hObject,'String')) returns contents of mean_interarrival_EDIT as a double


% --- Executes during object creation, after setting all properties.
function mean_interarrival_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mean_interarrival_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mean_service_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to mean_service_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mean_service_EDIT as text
%        str2double(get(hObject,'String')) returns contents of mean_service_EDIT as a double


% --- Executes during object creation, after setting all properties.
function mean_service_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mean_service_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_delays_required_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to num_delays_required_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_delays_required_EDIT as text
%        str2double(get(hObject,'String')) returns contents of num_delays_required_EDIT as a double


% --- Executes during object creation, after setting all properties.
function num_delays_required_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_delays_required_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Q_LIMIT_EDIT_Callback(hObject, eventdata, handles)
% hObject    handle to Q_LIMIT_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Q_LIMIT_EDIT as text
%        str2double(get(hObject,'String')) returns contents of Q_LIMIT_EDIT as a double


% --- Executes during object creation, after setting all properties.
function Q_LIMIT_EDIT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Q_LIMIT_EDIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.num_server_EDIT,'String',0);
set(handles.mean_interarrival_EDIT,'String',0);
set(handles.mean_service_EDIT,'String',0);
set(handles.num_delays_required_EDIT,'String',0);
set(handles.Q_LIMIT_EDIT,'String',0);

set(handles.rou_TEXT,'String', '');
set(handles.delay_in_queue_TEXT,'String','');
set(handles.delay_in_system_TEXT,'String','');
set(handles.number_in_queue_TEXT,'String','');
set(handles.server_utilization_TEXT,'String','');
set(handles.sim_time_TEXT,'String','');
guidata(hObject, handles);

% --- Executes on key press with focus on reset and none of its controls.
function reset_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function File_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to File_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Help_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to Help_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to Open_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile({'*.txt'});
if ~isequal(file, 0)
    open(file);
end


% --------------------------------------------------------------------
function Exit_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(['关闭 ' get(handles.figure1,'Name') '?'],...
    ['关闭 ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

% delete(handles.figure1)
close(gcf);

% --------------------------------------------------------------------
function Save_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to Save_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uiputfile('result.txt','保存');
hid=fopen('result.txt','w');
fprintf(hid, 'Multiple-server queueing system:\r\n');
fprintf(hid, 'Mean interarrival time%11.3f minutes\r\n',str2double(get(handles.mean_interarrival_EDIT,'String')) );
% fprintf(hid, 'Mean service time%16.3f minutes\r\n', mean_service);
% fprintf(hid, 'Number of servers%20d\r\n', num_serveCounter);
% fprintf(hid, 'Number of customers%14d\r\n', num_peo_required);
fclose(hid);

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function print_MENU_Callback(hObject, eventdata, handles)
% hObject    handle to print_MENU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% printdlg(handles.figure1);
