function varargout = main_form(varargin)
% MAIN_FORM MATLAB code for main_form.fig
%      MAIN_FORM, by itself, creates a new MAIN_FORM or raises the existing
%      singleton*.
%
%      H = MAIN_FORM returns the handle to a new MAIN_FORM or the handle to
%      the existing singleton*.
%
%      MAIN_FORM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_FORM.M with the given input arguments.
%
%      MAIN_FORM('Property','Value',...) creates a new MAIN_FORM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_form_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_form_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_form

% Last Modified by GUIDE v2.5 16-May-2016 18:13:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_form_OpeningFcn, ...
                   'gui_OutputFcn',  @main_form_OutputFcn, ...
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


% --- Executes just before main_form is made visible.
function main_form_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_form (see VARARGIN)

% Choose default command line output for main_form
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main_form wait for user response (see UIRESUME)
% uiwait(handles.main_form);


% --- Outputs from this function are returned to the command line.
function varargout = main_form_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function me_open_Callback(hObject, eventdata, handles)
% hObject    handle to me_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
all_data = guidata(gcbo);
[filename, pathname] = uigetfile('*.mat', 'Select a MATLAB code file');

if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   all_data.file_name = fullfile(pathname, filename);
   all_data.variables_info = whos('-file',all_data.file_name);
   all_data.variables_name = extractfield(all_data.variables_info, 'name');   
   set(handles.li_variables,'String',all_data.variables_name);
end
guidata(gcbo, all_data);

% --------------------------------------------------------------------
function me_exit_Callback(hObject, eventdata, handles)
% hObject    handle to me_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function bu_run_Callback(hObject, eventdata, handles)
% hObject    handle to bu_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmap = vertcat(jet(127), 0.3 + rand (128, 3) * 0.69, [1,1,1]); % view_events

all_data = guidata(gcbo);
selected_item = get(handles.li_variables,'Value');
disp(selected_item);
var_name = char(all_data.variables_name(selected_item));
info_log('Reading variable from file');
input_data = load(all_data.file_name, var_name);
on_bm3d_filtering = false;
if get(handles.cb_on_bm3d, 'Value')
   on_bm3d_filtering = true; 
end
[data_2d_video, bm3d_video, preprocessed_video, df_f0_video, events_3d, events_info] = ...
    astrocyte_research(input_data.(var_name), on_bm3d_filtering);
% all_data.data_2d_video = norm_data(input_data.(var_name), 127);
clear input_data;

% events_info = calc_events_info(events_3d);
events_stat = calc_statistics(events_info);

% Create players for 3 video streams
if isfield(all_data, 'data_player') && ishandle(all_data.data_player) 
    close(all_data.data_player)
end
data_2d_video = norm_data(data_2d_video, 127);
all_data.data_player = implay_map(data_2d_video, 2, [0 255], ...
    cmap, 'Video (2D format)');

if isfield(all_data, 'preproc_data_player') && ishandle(all_data.preproc_data_player) 
    close(all_data.preproc_data_player)
end
preprocessed_video = norm_data(preprocessed_video, 127);
all_data.preproc_data_player = implay_map(preprocessed_video, 2, ...
    [0 255], cmap, 'Preprocessed video (bm3d + smoothing)');

if isfield(all_data, 'dF_F0_player') && ishandle(all_data.dF_F0_player)
    close(all_data.dF_F0_player)
end
df_f0_video = norm_data(df_f0_video, 127);
all_data.dF_F0_player = implay_map(df_f0_video, 2, [0 255], cmap, 'dF/F0');


% Create list of events
handle_events_form = events_form();

data_events_form = guidata(handle_events_form);
events_list = cell(1, events_info.numbers);
for i = 1 : numel(events_list)
    event_list{i} = sprintf('id = %5d | start = %5d | finish = %5d | duration = %5d | max_projection = %7d', ...
                             events_info.ids(i), events_info.starts(i), ...
                             events_info.finishes(i), events_info.durations(i), ...
                             events_info.max_projections(i));
end
set(data_events_form.li_events, 'String', event_list);
set(data_events_form.la_num_events, 'String', events_info.numbers);

% Update data in global space
all_data.data_2d_video = data_2d_video;
all_data.bm3d_video = bm3d_video;
all_data.preprocessed_video = preprocessed_video;
all_data.df_f0_video = df_f0_video;
all_data.events_3d = events_3d;
all_data.events_info = events_info;
all_data.events_stat = events_stat;
view_all_distribution(events_info, all_data.events_stat, 'g');
guidata(gcbo, all_data);



% --- Executes on selection change in li_variables.
function li_variables_Callback(hObject, eventdata, handles)
% hObject    handle to li_variables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns li_variables contents as cell array
%        contents{get(hObject,'Value')} returns selected item from li_variables


% --- Executes during object creation, after setting all properties.
function li_variables_CreateFcn(hObject, eventdata, handles)
% hObject    handle to li_variables (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in li_log.
function li_log_Callback(hObject, eventdata, handles)
% hObject    handle to li_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns li_log contents as cell array
%        contents{get(hObject,'Value')} returns selected item from li_log


% --- Executes during object creation, after setting all properties.
function li_log_CreateFcn(hObject, eventdata, handles)
% hObject    handle to li_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function me_save_log_Callback(hObject, eventdata, handles)
% hObject    handle to me_save_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uiputfile('*.txt', 'Save log');

if isequal(filename,0)
   disp('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, filename)])
   file_name = fullfile(pathname, filename);
   log_strings = get(handles.li_log, 'String');
   info_log(sprintf('Saving logs to %s', file_name));
   save_log(log_strings, file_name);
end



% --- Executes on button press in cb_on_bm3d.
function cb_on_bm3d_Callback(hObject, eventdata, handles)
% hObject    handle to cb_on_bm3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_on_bm3d


% --------------------------------------------------------------------
function me_save_movie_makers_Callback(hObject, eventdata, handles)
% hObject    handle to me_save_movie_makers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj('Tag','main_form');
all_data = guidata(h);

dir_name = uigetdir;

if isequal(dir_name, 0)
   disp('User selected Cancel')
else
   disp(['User selected ', dir_name]);
   info_log(sprintf('Saving movies to .avi files (directory name is %s)', ...
       dir_name));
   save_results2video(all_data.data_2d_video, all_data.data_2d_video, ...
       all_data.bm3d_video, all_data.preprocessed_video, ...
       all_data.df_f0_video, all_data.events_3d, all_data.events_info, ...
       'splitted', dir_name);
end


% --------------------------------------------------------------------
function me_save_steps_Callback(hObject, eventdata, handles)
% hObject    handle to me_save_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = findobj('Tag','main_form');
all_data = guidata(h);

[filename, pathname] = uiputfile('*.avi', 'Save .avi file');

if isequal(filename,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(pathname, filename)]);
   file_name = fullfile(pathname, filename); 
   info_log(sprintf('Saving steps to %s', file_name));
   save_results2video(all_data.data_2d_video, all_data.data_2d_video, ...
       all_data.bm3d_video, all_data.preprocessed_video, ...
       all_data.df_f0_video, all_data.events_3d, all_data.events_info, ...
       'merged', file_name);
end

