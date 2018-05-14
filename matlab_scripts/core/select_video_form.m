function varargout = select_video_form(varargin)
    % select_video_form MATLAB code for select_video_form.fig
    %      select_video_form, by itself, creates a new select_video_form or raises the existing
    %      singleton*.
    %
    %      H = select_video_form returns the handle to a new select_video_form or the handle to
    %      the existing singleton*.
    %
    %      select_video_form('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in select_video_form.M with the given input arguments.
    %
    %      select_video_form('Property','Value',...) creates a new select_video_form or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before select_video_form_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to select_video_form_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help select_video_form
    
    % Last Modified by GUIDE v2.5 31-Aug-2017 12:38:34
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name', mfilename, ...
        'gui_Singleton', gui_Singleton, ...
        'gui_OpeningFcn', @select_video_form_OpeningFcn, ...
        'gui_OutputFcn', @select_video_form_OutputFcn, ...
        'gui_LayoutFcn', [], ...
        'gui_Callback', []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
    
    % --- Executes just before select_video_form is made visible.
function select_video_form_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to select_video_form (see VARARGIN)
    
    % Choose default command line output for select_video_form
    handles.output = hObject;
    
    handles.output = '';
    handles.tbl_vars.Data = cell(0, 3);
    
    handles.select_video_form.Name = varargin{2};
    
    % Update handles structure
    guidata(hObject, handles);
    
    all_data = guidata(hObject);
    all_data.channel_mask = ...
        logical([handles.cb_red_channel.Value, ...
        handles.cb_green_channel.Value, ...
        handles.cb_blue_channel.Value]);
    guidata(hObject, all_data);
    
    % UIWAIT makes select_video_form wait for user response (see UIRESUME)
    uiwait(handles.select_video_form);
    
    % --- Outputs from this function are returned to the command line.
function varargout = select_video_form_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    delete(hObject);
    
    % --- Executes on button press in bu_select_video.
function bu_select_video_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_select_video (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    video_info = all_data.video_info;
    
    video_info.real_size = ...
        [str2double(handles.ed_frames_per_sec.String), ...
        str2double(handles.ed_real_height.String), ...
        str2double(handles.ed_real_width.String)];
    video_info.channel_mask = all_data.channel_mask;
    
    handles.output = video_info;
    guidata(hObject, handles);
    
    select_video_form_CloseRequestFcn(handles.select_video_form, eventdata, handles);
    
    %delete (handles.select_video_form);
    
function ed_data_location_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_data_location (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_data_location as text
    %        str2double(get(hObject,'String')) returns contents of ed_data_location as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_data_location_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_data_location (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
    % --- Executes on button press in bu_browse.
function bu_browse_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_browse (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    update_channel_mask(handles);
    all_data = guidata(gcbo);
    
    video_info.var_name = '';
    data_location = handles.ed_data_location.String;
    switch handles.rgr_data_type.SelectedObject.Tag
        case 'rb_mat'
            if exist(data_location, 'dir') ~= 7
                data_location = '../../data/2013-05-22_fileNo03_z-max_short.mat';
            end
            [filename, pathname] = ...
                uigetfile('*.mat', ...
                'Select a MATLAB data file', ...
                data_location);
            if isequal(filename, 0)
                disp('User selected Cancel')
                return;
            else
                disp(['User selected ', fullfile(pathname, filename)])
                video_info.file_name = fullfile(pathname, filename);
                
                oldpointer = get(handles.select_video_form, 'pointer');
                set(handles.select_video_form, 'pointer', 'watch');
                drawnow;
                video_info.data_file = matfile(video_info.file_name);
                video_info.variables_info = whos(video_info.data_file);
                set(handles.select_video_form, 'pointer', oldpointer);
                
                vars = {};
                for i = 1:length(video_info.variables_info)
                    cur_size = video_info.variables_info(i).size;
                    if (length(cur_size) ~= 3) && ...
                            ~((length(cur_size) == 4) && (cur_size(4) == 3))
                        continue;
                    end
                    vars{end + 1, 1} = video_info.variables_info(i).name;
                    
                    cur_class = video_info.variables_info(i).class;
                    str_value = sprintf('%s %s', size_to_str(cur_size), cur_class);
                    vars{end, 2} = str_value;
                    vars{end, 3} = video_info.variables_info(i).bytes;
                end
                if isempty(vars)
                    disp('File doesn''t contain 3d variables');
                    return;
                end
                var_name = vars{1, 1};
                video_info.data_dir = pathname;
                video_info.data_files = filename;
                video_info.data_type = 'mat';
                
                video_info = update_mat_info(video_info, var_name, ...
                    handles, all_data.channel_mask);
                
                set(handles.tbl_vars, 'Data', vars);
            end
        case 'rb_tif'
            [filename, pathname] = ...
                uigetfile('*.tif', ...
                'Select a TIF video file', ...
                data_location);
            if isequal(filename, 0)
                disp('User selected Cancel')
                return;
            else
                disp(['User selected ', fullfile(pathname, filename)])
                video_info.file_name = fullfile(pathname, filename);
                video_info.data_dir = pathname;
                video_info.data_files = filename;
                video_info.data_type = 'tif';
                [video_info.size, video_info.load_preview] = ...
                    get_data_info(video_info.data_dir, ...
                    video_info.data_files, ...
                    video_info.data_type, ...
                    all_data.channel_mask);
            end
        case 'rb_imlist'
            [filelist, pathname] = ...
                uigetfile('*.jpg;*.png;*.bmp;*.jpeg;*.tif', ...
                'Select a multiple images', ...
                data_location, 'MultiSelect', 'on');
            if ~iscell(filelist)
                filelist = {filelist};
            end
            if isequal(filelist, 0) || isequal(filelist, {0})
                disp('User selected Cancel')
                return;
            else
                disp(['User selected ', pathname]);
                video_info.file_name = fullfile(pathname, filelist{1});
                video_info.data_dir = pathname;
                video_info.data_files = filelist;
                video_info.data_type = 'imlist';
                [video_info.size, video_info.load_preview] = ...
                    get_data_info(video_info.data_dir, ...
                    video_info.data_files, ...
                    video_info.data_type, ...
                    all_data.channel_mask);
            end
    end
    
    if video_info.size(3) < 2
        return;
    end
    
    if ~strcmp(video_info.data_type, 'mat')
        set(handles.tbl_vars, 'Data', cell(0, 3));
    end
    
    handles.bu_select_video.Enable = 'on';
    
    all_data.video_info = video_info;
    guidata(gcbo, all_data);
    
    update_channel_mask(handles);
    update_gui_info(handles);
    
function video_info = update_mat_info(video_info, var_name, ...
        handles, channel_mask)
    oldpointer = get(handles.select_video_form, 'pointer');
    set(handles.select_video_form, 'pointer', 'watch');
    drawnow;
    id = 1;
    for i = 1:length(video_info.variables_info)
        if strcmp(video_info.variables_info(i).name, var_name)
            id = i;
        end
    end
    video_info.size = video_info.variables_info(id).size;
    
    [video_info.size, video_info.load_preview] = ...
        get_data_info(video_info.data_dir, ...
        video_info.data_file, ...
        video_info.data_type, ...
        var_name, ...
        channel_mask);
    video_info.var_name = var_name;
    set(handles.select_video_form, 'pointer', oldpointer);
    
function update_gui_info(handles)
    all_data = guidata(gcbo);
    if ~isfield(all_data, 'video_info')
        return;
    end
    video_info = all_data.video_info;
    if iscell(video_info.data_files)
        filelist = strjoin(video_info.data_files, '; ');
    else
        filelist = video_info.data_files;
    end
    set(handles.ed_files_names, 'String', filelist);
    set(handles.ed_data_location, 'String', video_info.data_dir);
    set(handles.ed_frames, 'String', video_info.size(3));
    set(handles.ed_height, 'String', video_info.size(1));
    set(handles.ed_width, 'String', video_info.size(2));
    if size(video_info.preview, 3) == 3
        imshow(video_info.preview, ...
            'Parent', handles.ax_preview);
    else
        imshow(video_info.preview, ...
            [min(video_info.preview(:)), max(video_info.preview(:))], ...
            'Parent', handles.ax_preview, 'Colormap', jet(255));
    end
    
function ed_project_name_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_project_name (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_project_name as text
    %        str2double(get(hObject,'String')) returns contents of ed_project_name as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_project_name_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_project_name (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
    % --- Executes on button press in bu_cancel.
function bu_cancel_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_cancel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % delete(handles.select_video_form);
    select_video_form_CloseRequestFcn(handles.select_video_form, eventdata, handles);
    
function ed_files_names_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_files_names (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_files_names as text
    %        str2double(get(hObject,'String')) returns contents of ed_files_names as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_files_names_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_files_names (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
function ed_frames_per_sec_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_frames_per_sec (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_frames_per_sec as text
    %        str2double(get(hObject,'String')) returns contents of ed_frames_per_sec as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_frames_per_sec_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_frames_per_sec (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
function ed_real_height_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_real_height (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_real_height as text
    %        str2double(get(hObject,'String')) returns contents of ed_real_height as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_real_height_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_real_height (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
function ed_real_width_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_real_width (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_real_width as text
    %        str2double(get(hObject,'String')) returns contents of ed_real_width as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_real_width_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_real_width (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
function ed_frames_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_frames (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_frames as text
    %        str2double(get(hObject,'String')) returns contents of ed_frames as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_frames_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_frames (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
function ed_height_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_height (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_height as text
    %        str2double(get(hObject,'String')) returns contents of ed_height as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_height_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_height (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
function ed_width_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_width (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_width as text
    %        str2double(get(hObject,'String')) returns contents of ed_width as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_width_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_width (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
    % --- Executes when user attempts to close select_video_form.
function select_video_form_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to select_video_form (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: delete(hObject) closes the figure
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end
    
    % --- Executes when selected cell(s) is changed in tbl_vars.
function tbl_vars_CellSelectionCallback(hObject, eventdata, handles)
    % hObject    handle to tbl_vars (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %    Indices: row and column indices of the cell(s) currently selecteds
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    
    if ~strcmp(handles.rgr_data_type.SelectedObject.Tag, 'rb_mat')
        return;
    end
    if isempty(eventdata.Indices)
        all_data.var_selected = 1;
    else
        all_data.var_selected = eventdata.Indices(1);
    end
    
    var_name = all_data.tbl_vars.Data{all_data.var_selected, 1};
    video_info = all_data.video_info;
    if strcmp(video_info.var_name, var_name)
        return;
    end
    video_info = update_mat_info(video_info, ...
        var_name, ...
        handles, all_data.channel_mask);
    all_data.video_info = video_info;
    guidata(gcbo, all_data);
    
    update_channel_mask(handles);
    update_gui_info(handles);
    
    % --- Executes during object creation, after setting all properties.
function tbl_vars_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to tbl_vars (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % --- Executes when selected object is changed in rgr_data_type.
function rgr_data_type_SelectionChangedFcn(hObject, eventdata, handles)
    % hObject    handle to the selected object in rgr_data_type
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if strcmp(handles.rgr_data_type.SelectedObject.Tag, 'rb_mat')
        handles.tbl_vars.Enable = 'on';
    else
        handles.tbl_vars.Enable = 'off';
    end
    
    % --- Executes on button press in cb_red_channel.
function cb_red_channel_Callback(hObject, eventdata, handles)
    % hObject    handle to cb_red_channel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of cb_red_channel
    update_channel_mask(handles);
    update_gui_info(handles)
    
    % --- Executes on button press in cb_green_channel.
function cb_green_channel_Callback(hObject, eventdata, handles)
    % hObject    handle to cb_green_channel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of cb_green_channel
    update_channel_mask(handles);
    update_gui_info(handles)
    
    % --- Executes on button press in cb_blue_channel.
function cb_blue_channel_Callback(hObject, eventdata, handles)
    % hObject    handle to cb_blue_channel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of cb_blue_channel
    update_channel_mask(handles);
    update_gui_info(handles)
    
function update_channel_mask(handles)
    all_data = guidata(gcbo);
    all_data.channel_mask = ...
        logical([handles.cb_red_channel.Value, ...
        handles.cb_green_channel.Value, ...
        handles.cb_blue_channel.Value]);
    if isfield(all_data, 'video_info') && ...
            isfield(all_data.video_info, 'load_preview')
        all_data.video_info.preview = image_channel_mask ...
            (all_data.video_info.load_preview, all_data.channel_mask);
    end
    guidata(gcbo, all_data);
