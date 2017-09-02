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

ST_Idle=0;%%%����̨Ϊ����
ST_Busy=1;%%%����̨Ϊ��æ
ST_All_Busy=-1;%%%���з���̨Ϊ��æ
EV_NULL=0;
EV_Arrive=1;
EV_Depart=2;
EV_LEN=3;
Q_LIMIT=str2double(get(handles.Q_LIMIT_EDIT,'String'))  ;                %%%%%%%%%%�Ŷ�ϵͳ����
Q_LIMIT=1e10;

time_arrival=[];                 %����ʱ��
time_next_event=zeros(1,EV_LEN);
%�������
num_events=EV_LEN-1;
num_serveCounter=num_serverTemp;                  %%%%M/M/m  mΪ����̨����
mean_interarrival=str2double(get(handles.mean_interarrival_EDIT,'String'))  ;      %%%%%�˿�ƽ��������ʱ��
mean_service=str2double(get(handles.mean_service_EDIT,'String'))  ;             %%%%%Ϊ�˿ͷ���ƽ������ʱ��
num_peo_required=str2double(get(handles.num_delays_required_EDIT,'String'))  ;           %%%%%%%�˿���Դ����

serv_time=zeros(1,num_peo_required);
outfile=fopen('MMc.txt','w');
fprintf(outfile, 'MMc�����̨�Ŷӷ���ϵͳ��\r\n');
fprintf(outfile, 'ƽ��������ʱ��Ϊ%11.3f minutes\r\n',mean_interarrival);
fprintf(outfile, 'ƽ������ʱ��Ϊ%16.3f minutes\r\n', mean_service);
fprintf(outfile, '����̨��Ϊ%20d\r\n', num_serveCounter);
fprintf(outfile, '�˿�����Ϊ%14d\r\n', num_peo_required);

%part1 ��ʼ��
sim_time=0.0;
server_status   =zeros(1,num_serveCounter);   %״̬����
num_in_q        = 0;%��������
time_last_event = 0.0;%�¼�����ʱ��
num_custs_simulated  = 0;%%%�Ѿ���ɷ���Ĺ˿�����
total_of_delays    = 0.0;%%%%%%�����й˿͵ȴ��ܵ�ʱ��
total_of_time    = 0.0;%%%%%%ϵͳ�й˿Ͷ�����ʱ��
area_num_in_q      = 0.0;
area_server_status = 0.0;

%/* Initialize event list. ��ʼ�¼�����Ϊû�й˿͵�����ܷ����뿪�¼�ʱ�̳�ʼΪ�����*/
time_next_event(EV_Arrive) = sim_time + exprnd(mean_interarrival);%%��¼ʱ���¼�����һ�����¼�ʱ��
time_next_event(EV_Depart) = 1.0e+230;%%��¼ʱ���¼�����һ�뿪�¼�ʱ��

time_serveDepart=zeros(1,num_serveCounter);%%%��¼ÿ������̨ʵ���еĹ˿ͣ�������Ϻ��뿪�˷���̨��ʱ��
ordinal_serveCounter_depart=0;
    
%part2  
while (num_custs_simulated < num_peo_required)
%/*�����´η���ʲô�¼� */
min_time_next_event = 1.0e+290;
%  �ҳ�time_serveDepart(1,:)��Сֵ����Ӧ���±�i����ordinal_serveCounter_depart��ȷ����ǰʱ�̵ڼ�������̨�еĹ˿������뿪
min_time_serveDepart=1e290;
ordinal_serveCounter_depart=0;
for i=1:num_serveCounter%%%%%%% Ҳ����[val,pos]=min(time_serveDepart)���棬�ó�val��pos
    if(server_status(i)==1 && time_serveDepart(i)<min_time_serveDepart)
        min_time_serveDepart=time_serveDepart(i);
        ordinal_serveCounter_depart=i;
    end
end
time_next_event(2)=min_time_serveDepart;

%/* ȷ����һ���緢���¼������ͣ� 1����Arrive��2����Departure */ 
next_event_type = 0;
for i = 1: num_events
    if (time_next_event(i) < min_time_next_event)
        min_time_next_event = time_next_event(i);
        next_event_type     = i;
    end
end

%/* �¼��б��Ƿ�Ϊ��. */
if (next_event_type == 0)
    % ���¼�����ֹ����
    fprintf(outfile, '\r\nEvent list empty at time %f', sim_time);
    exit(1);
end
%/* �¼����գ��ƽ�����ʱ�ӵ���һ����ʱ��*/
sim_time = min_time_next_event;
double time_since_last_event; %%%�շ����¼�����ʱ��
time_since_last_event = sim_time - time_last_event;
time_last_event       = sim_time;
%/* ���¶����еģ�����*�Ŷ�ʱ�䣩��Ϊ�˼���ƽ�����г��������е�ƽ���˿���/
area_num_in_q=area_num_in_q +  num_in_q * time_since_last_event;
%/* Ϊ�˼���ƽ���ӳ���ϵͳ�е�ƽ���˿��� */
for i=1:num_serveCounter
    area_server_status =area_server_status + server_status(i) * time_since_last_event;
end

%/* Invoke the appropriate event function. */
%arrival
if(next_event_type==EV_Arrive)
    double delay;  
    %/* �ҳ���ordinal_serveCounter������̨�ǿ���ST_Idle�����Ұ��պ���С���������ҵ�С�ŷ���̨����break*/
    ordinal_serveCounter=ST_All_Busy;
    for i=1:num_serveCounter
        if (server_status(i) == ST_Idle)
            ordinal_serveCounter=i;
            break;
        end
    end
    %/* ���з���̨æ���ӳ���1. */
    if(ordinal_serveCounter==ST_All_Busy)
        num_in_q=1+num_in_q;
        %/* check���������Ƿ����� */
        if (num_in_q > Q_LIMIT)
            %/* ����������������ֹ����. */
            fprintf(outfile, '\r\nOverflow of the array time_arrival at');
            fprintf(outfile, ' time %f', sim_time);
            exit(2);
        end
        %/* ���������������пռ�, ���漴������˿͵�ʱ���ڶ���ĩβ. */
        time_arrival(length(time_arrival)+1)=sim_time;
    else      
%/* num_custs_simulated��1���÷���̨æ. */
        num_custs_simulated = 1 + num_custs_simulated;
        server_status(ordinal_serveCounter) = ST_Busy;
        %/* �����˹˿��뿪ʱ��. */
        serv_time(num_custs_simulated)=exprnd(mean_service);
        time_serveDepart(ordinal_serveCounter) = sim_time + serv_time(num_custs_simulated);
    end
      %/* Schedule �´ε����¼�. */
  time_next_event(1) = sim_time + exprnd(mean_interarrival);
    
else%(next_event_type==EV_Depart)
    double delay;
    %/* check�����Ƿ�Ϊ��. */
    if (num_in_q == 0)
        % /*�øոչ˿��뿪�ķ���̨Ϊ����*/
        server_status(ordinal_serveCounter_depart)      = ST_Idle;
        time_serveDepart(ordinal_serveCounter_depart) = 1.0e+230;
    else
        %/* ���зǿգ����г���ȥ1. */
        num_in_q=num_in_q-1;        
        %/*��������˿��Ŷӵȴ�ʱ�䣬�������Ŷӵȴ�ʱ��. */        
        delay = sim_time - time_arrival(1);
        total_of_delays =total_of_delays + delay;  %%%%%total_of_delays�������Ŷ���ʱ��        
        %/* �������ϵͳ�õ������������1, �����˹˿��뿪ʱ�� */        
        num_custs_simulated = 1 + num_custs_simulated;
        serv_time(num_custs_simulated)=exprnd(mean_service);%mean_service
        time_serveDepart(ordinal_serveCounter_depart) = sim_time + serv_time(num_custs_simulated);    
        
        %/*�����еĹ˿���ǰ��λ���ڶ��������ף�����ǰ�ơ��� */
        tempForPop=time_arrival(2:length(time_arrival));
        time_arrival=tempForPop;
    end %if (num_in_q == 0)
end %if(next_event_type==EV_Arrive)
end %while


%%%%%%%%%% part 3
%/*���Little��ʽ������*/
fprintf(outfile, '\r\nLittle��ʽ�������� \r\n');
rou=mean_service/mean_interarrival/num_serveCounter;%%%%%%%%%%����̨�����ʼ�����ǿ����Little��ʽֱ�Ӽ���õ���
fprintf(outfile, 'ϵͳ������rou=mean_service/mean_interarrival/num_serveCounter %8.3f \r\n',rou);
%%%%%%%%%%%%%%%%%%%---------------����Ϊ���ж����̨Little���㹫ʽ��---------
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

%%%%%%%%%%%%%%%%%%%---------------��Ϊ���е�����̨Little���㹫ʽ��---------
%     Ws=1/(u-Lambda);%%Little��ʽֱ�Ӽ���õ�ϵͳ�й˿�ƽ������ʱ��
%     Ls=Lambda*Ws;%%Little��ʽֱ�Ӽ���õ��ӳ���ϵͳ�е�ƽ���˿���
%     Wq=rou/(u-Lambda);%%Little��ʽֱ�Ӽ���õ������й˿�ƽ���ȴ�ʱ��
%     Lq=Lambda*Wq;%%Little��ʽֱ�Ӽ���õ��ŶӶ��г��������е�ƽ���˿���
%     fprintf(outfile, 'Wq=rou/(u-Lambda);%%Little��ʽֱ�Ӽ���õ������й˿�ƽ���ȴ�ʱ�� %11.3f \r\n',Wq);
%     fprintf(outfile, 'Ws=1/(u-Lambda);%%Little��ʽֱ�Ӽ���õ�ϵͳ�й˿�ƽ������ʱ�� %11.3f \r\n',Ws);
%      fprintf(outfile, '  Lq=Lambda*Wq;%%Little��ʽֱ�Ӽ���õ��ŶӶ��г��������е�ƽ���˿��� %11.3f \r\n',Lq);
%      fprintf(outfile, ' Ls=Lambda*Ws;%%Little��ʽֱ�Ӽ���õ��ӳ���ϵͳ�е�ƽ���˿��� %11.3f \r\n',Ls);
%   %%%%%%%%%%%%%%------------------------��Ϊ���е�����̨Little���㹫ʽ��---------

fprintf(outfile, '����ϵͳ���еĸ��� P0 %11.3f \r\n',P0);
fprintf(outfile, '�����й˿�ƽ���ȴ�ʱ�� Wq %11.3f \r\n',Wq);
fprintf(outfile, 'ϵͳ�й˿�ƽ������ʱ��Ws %11.3f \r\n',Ws);
fprintf(outfile, '�ŶӶ��г��������е�ƽ���˿���Lq %11.3f \r\n',Lq);
fprintf(outfile, '�ӳ��� ϵͳ �е�ƽ���˿���Ls  %11.3f%\r\n\r\n',Ls);

%/* ��������� */
 sum_serv_time=0;
for i=1:num_peo_required
    sum_serv_time=sum_serv_time+serv_time(i);
end
total_of_time =total_of_delays +sum_serv_time; %%%%%total_of_time�������ŶӼӷ������ʱ��
delay_in_queue=total_of_delays / num_custs_simulated;
delay_in_system=total_of_time / num_custs_simulated;
number_in_queue=area_num_in_q / sim_time;
number_in_serve=area_server_status / sim_time;
number_in_system=number_in_queue+number_in_serve;
server_utilization=area_server_status / sim_time/num_serveCounter;

fprintf(outfile, '\r\n\r\n��������\r\n');
fprintf(outfile, 'ϵͳ������%15.3f\r\n',server_utilization );  %%%%%%%%%%����̨�����ʼ�����ǿ���з���õ���
fprintf(outfile, '�����й˿�ƽ���ȴ�ʱ��Wq %11.3f minutes\r\n',delay_in_queue);
fprintf(outfile, 'ϵͳ�й˿�ƽ������ʱ�� Ws%11.3f minutes\r\n',delay_in_system);
fprintf(outfile, '���г��������е�ƽ���˿���Lq%11.3f\r\n',number_in_queue);
fprintf(outfile, '�ӳ���ϵͳ�е�ƽ���˿���Ls%11.3f\r\n',number_in_system);
fprintf(outfile, 'ϵͳ�ķ���ʱ��%15.3f minutes', sim_time);
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

selection = questdlg(['�ر� ' get(handles.figure1,'Name') '?'],...
    ['�ر� ' get(handles.figure1,'Name') '...'],...
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
[file,path] = uiputfile('result.txt','����');
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
