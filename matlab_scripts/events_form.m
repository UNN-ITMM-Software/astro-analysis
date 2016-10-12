function varargout = events_form(varargin)
% EVENTS_FORM MATLAB code for events_form.fig
%      EVENTS_FORM, by itself, creates a new EVENTS_FORM or raises the existing
%      singleton*.
%
%      H = EVENTS_FORM returns the handle to a new EVENTS_FORM or the handle to
%      the existing singleton*.
%
%      EVENTS_FORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVENTS_FORM.M with the given input arguments.
%
%      EVENTS_FORM('Property','Value',...) creates a new EVENTS_FORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before events_form_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to events_form_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help events_form

% Last Modified by GUIDE v2.5 20-Apr-2016 13:41:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @events_form_OpeningFcn, ...
                   'gui_OutputFcn',  @events_form_OutputFcn, ...
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


% --- Executes just before events_form is made visible.
function events_form_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to events_form (see VARARGIN)

% Choose default command line output for events_form
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes events_form wait for user response (see UIRESUME)
% uiwait(handles.events_form);


% --- Outputs from this function are returned to the command line.
function varargout = events_form_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in li_events.
function li_events_Callback(hObject, eventdata, handles)
% hObject    handle to li_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns li_events contents as cell array
%        contents{get(hObject,'Value')} returns selected item from li_events


% --- Executes during object creation, after setting all properties.
function li_events_CreateFcn(hObject, eventdata, handles)
% hObject    handle to li_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bu_draw_events.
function bu_draw_events_Callback(hObject, eventdata, handles)
% hObject    handle to bu_draw_events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj('Tag','main_form');
ids = get(handles.li_events, 'Value');
all_data = guidata(h);
if get(handles.cb_source, 'Value')    
    all_data.data_player.DataSource.DataHandler.UserData(:,:,:) = ...
        view_events(all_data.events_3d, all_data.events_info, ids, all_data.data_2d_video);
end

if get(handles.cb_bm3d, 'Value')
    all_data.preproc_data_player.DataSource.DataHandler.UserData(:,:,:) = ...
        view_events(all_data.events_3d, all_data.events_info, ids, all_data.preprocessed_video);
end

if get(handles.cb_df_f0, 'Value')
    all_data.dF_F0_player.DataSource.DataHandler.UserData(:,:,:) = ...
        view_events(all_data.events_3d, all_data.events_info, ids, all_data.df_f0_video);
end
guidata(h, all_data);



% --- Executes on button press in cb_source.
function cb_source_Callback(hObject, eventdata, handles)
% hObject    handle to cb_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_source


% --- Executes on button press in cb_bm3d.
function cb_bm3d_Callback(hObject, eventdata, handles)
% hObject    handle to cb_bm3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_bm3d


% --- Executes on button press in cb_df_f0.
function cb_df_f0_Callback(hObject, eventdata, handles)
% hObject    handle to cb_df_f0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_df_f0



% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function save_events_info_Callback(hObject, eventdata, handles)
% hObject    handle to save_events_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h = findobj('Tag','main_form');
all_data = guidata(h);
[filename, pathname] = uiputfile({'*.csv'; '*.txt'}, 'Save as');

if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   file_name = sprintf('%s%s', pathname, filename);
   save_events_info(all_data.events_info, file_name);
end
