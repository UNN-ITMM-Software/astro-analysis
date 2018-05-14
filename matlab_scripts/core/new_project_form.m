function varargout = new_project_form(varargin)
    % SELECT_VIDEO_FORM MATLAB code for select_video_form.fig
    %      SELECT_VIDEO_FORM, by itself, creates a new SELECT_VIDEO_FORM or raises the existing
    %      singleton*.
    %
    %      H = SELECT_VIDEO_FORM returns the handle to a new SELECT_VIDEO_FORM or the handle to
    %      the existing singleton*.
    %
    %      SELECT_VIDEO_FORM('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in SELECT_VIDEO_FORM.M with the given input arguments.
    %
    %      SELECT_VIDEO_FORM('Property','Value',...) creates a new SELECT_VIDEO_FORM or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before new_project_form_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to new_project_form_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help select_video_form
    
    % Last Modified by GUIDE v2.5 01-Sep-2017 13:02:02
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name', mfilename, ...
        'gui_Singleton', gui_Singleton, ...
        'gui_OpeningFcn', @new_project_form_OpeningFcn, ...
        'gui_OutputFcn', @new_project_form_OutputFcn, ...
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
function new_project_form_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to select_video_form (see VARARGIN)
    
    % Choose default command line output for select_video_form
    handles.output = hObject;
    
    handles.output = '';
    handles.tbl_vars.Data = cell(0, 3);
    
    % Update handles structure
    guidata(hObject, handles);
    
    all_data = guidata(hObject);
    all_data.num_video = 0;
    guidata(hObject, all_data);
    
    % UIWAIT makes select_video_form wait for user response (see UIRESUME)
    uiwait(handles.new_project_form);
    
    % --- Outputs from this function are returned to the command line.
function varargout = new_project_form_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    delete(hObject);
    
    % --- Executes on button press in bu_create_project.
function bu_create_project_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_create_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    oldpointer = get(handles.new_project_form, 'pointer');
    set(handles.new_project_form, 'pointer', 'watch');
    drawnow;
    
    all_data = guidata(gcbo);
    new_project = all_data.new_project;
    
    new_project.project_name = handles.ed_project_name.String;
    
    project = create_project(new_project.project_name, ...
        new_project.astro_video_info, new_project.noise_video_info);
    
    handles.output = project;
    guidata(hObject, handles);
    
    set(handles.new_project_form, 'pointer', oldpointer);
    
    new_project_form_CloseRequestFcn(handles.new_project_form, eventdata, handles);
    
    % --- Executes on button press in bu_browse_1.
function bu_browse_1_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_browse_1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    astro_video_info = select_video_form([], 'Select video data with astrocyte');
    
    if isempty(astro_video_info)
        return;
    end
    all_data.new_project.astro_video_info = astro_video_info;
    
    all_data.num_video = bitor(all_data.num_video, 1);
    if all_data.num_video == 3
        handles.bu_create_project.Enable = 'on';
    end
    
    guidata(gcbo, all_data);
    
    update_gui_info(handles);
    
function update_gui_info(handles)
    all_data = guidata(gcbo);
    new_project = all_data.new_project;
    if isfield(new_project, 'astro_video_info')
        if iscell(new_project.astro_video_info.data_files)
            file_name = new_project.astro_video_info.data_dir;
            while (file_name(end) == '/' || file_name(end) == '\')
                file_name(end) = [];
            end
        else
            file_name = new_project.astro_video_info.file_name;
        end
        [~, file_name, ~] = fileparts(file_name);
        
        set(handles.ed_project_name, 'String', file_name);
        set(handles.ed_astro_location, 'String', new_project.astro_video_info.data_dir);
    end
    if isfield(new_project, 'noise_video_info')
        set(handles.ed_noise_location, 'String', new_project.noise_video_info.data_dir);
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
    % delete(handles.new_project_form);
    new_project_form_CloseRequestFcn(handles.new_project_form, eventdata, handles);
    
    % --- Executes when user attempts to close new_project_form.
function new_project_form_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to new_project_form (see GCBO)
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
    
    % --- Executes on button press in bu_browse_2.
function bu_browse_2_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_browse_2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    
    noise_video_info = select_video_form([], 'Select video data without astrocyte');
    
    if isempty(noise_video_info)
        return;
    end
    all_data.new_project.noise_video_info = noise_video_info;
    
    all_data.num_video = bitor(all_data.num_video, 2);
    if all_data.num_video == 3
        handles.bu_create_project.Enable = 'on';
    end
    
    guidata(gcbo, all_data);
    
    update_gui_info(handles);
    
function ed_astro_location_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_astro_location (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_astro_location as text
    %        str2double(get(hObject,'String')) returns contents of ed_astro_location as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_astro_location_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_astro_location (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
function ed_noise_location_Callback(hObject, eventdata, handles)
    % hObject    handle to ed_noise_location (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of ed_noise_location as text
    %        str2double(get(hObject,'String')) returns contents of ed_noise_location as a double
    
    % --- Executes during object creation, after setting all properties.
function ed_noise_location_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to ed_noise_location (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
