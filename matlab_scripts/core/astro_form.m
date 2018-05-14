function varargout = astro_form(varargin)
    % ASTRO_FORM MATLAB code for astro_form.fig
    %      ASTRO_FORM, by itself, creates a new ASTRO_FORM or raises the existing
    %      singleton*.
    %
    %      H = ASTRO_FORM returns the handle to a new ASTRO_FORM or the handle to
    %      the existing singleton*.
    %
    %      ASTRO_FORM('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in ASTRO_FORM.M with the given input arguments.
    %
    %      ASTRO_FORM('Property','Value',...) creates a new ASTRO_FORM or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before astro_form_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to astro_form_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help astro_form
    
    % Last Modified by GUIDE v2.5 07-May-2018 10:47:44
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name', mfilename, ...
        'gui_Singleton', gui_Singleton, ...
        'gui_OpeningFcn', @astro_form_OpeningFcn, ...
        'gui_OutputFcn', @astro_form_OutputFcn, ...
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
    
    % --- Executes just before astro_form is made visible.
function astro_form_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to astro_form (see VARARGIN)
    
    % Choose default command line output for astro_form
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes astro_form wait for user response (see UIRESUME)
    % uiwait(handles.astro_form);
    
    %% Create log tab
    margin = 0;
    handles.tab_log = tabplot('Log messages', handles.tbg_log, 'bottom');
    handles.li_log = uicontrol(handles.tab_log, 'style', 'listbox', ...
        'Tag', 'li_log', ...
        'Units', 'Normalized', ...
        'Position', [margin, margin, 1 - 2 * margin, 1 - 2 * margin], ...
        'FontName', 'Segoe UI');
    
    handles.cb_follow_log = uicontrol(handles.tab_log, 'style', 'checkbox', ...
        'Tag', 'cb_follow_log', ...
        'Units', 'Normalized', ...
        'TooltipString', 'Follow log', ...
        'Position', [1 - 0.05, 1 - 0.07, 0.025, 0.05], ...
        'FontName', 'Segoe UI', ...
        'BackgroundColor', [1, 1, 1, 0]);
    
    handles.tab_output = tabplot('Console output', handles.tbg_log);
    handles.li_output = uicontrol(handles.tab_output, 'style', 'listbox', ...
        'Tag', 'li_output', ...
        'Units', 'Normalized', ...
        'Position', [margin, margin, 1 - 2 * margin, 1 - 2 * margin], ...
        'FontName', 'Segoe UI');
    
    set(findobj(handles.tbg_log, 'Tag', 'tabplot:uitabgroup'), ...
        'SelectedTab', handles.tab_log);
    
    %grayImage = imread('moon.tif');
    %fig_preview = imshow(grayImage, 'Parent', handles.ax_preview);
    
    %% Create calculus/windows tab
    
    handles.tab_calculus = tabplot('Calculus', handles.tbg_calculus, 'top');
    margin = 0;
    set(handles.tbl_calculus, 'Parent', handles.tab_calculus);
    set(handles.tbl_calculus, 'Units', 'Normalized', ...
        'Position', [margin, margin, 1 - 2 * margin, 1 - 2 * margin]);
    
    handles.tab_windows = tabplot('Windows', handles.tbg_calculus, 'top');
    set(handles.tbl_windows, 'Parent', handles.tab_windows);
    set(handles.tbl_windows, 'Units', 'Normalized', ...
        'Position', [margin, margin, 1 - 2 * margin, 1 - 2 * margin]);
    
    set(findobj(handles.tbg_calculus, 'Tag', 'tabplot:uitabgroup'), ...
        'SelectedTab', handles.tab_calculus);
    
    set(handles.tbg_calculus, 'Units', 'Normalized', ...
        'Position', [margin, 0.22, 1 - 2 * margin, 1 - 0.22]);
    %% Table projects
    handles.tbl_projects.Data = cell(0, 2);
    
    %% Progress bar
    handles.ax_progress = uiProgressBar(handles.pa_progress);
    update_progress(handles, -1);
    
    %% Timer for updating memory used
    handles.tm_update_mem = ...
        timer('ObjectVisibility', 'Off', ...
        'ExecutionMode', 'fixedRate', ...
        'Period', 5, ...
        'TimerFcn', {@update_memory_used, handles.la_memory_used});
    start(handles.tm_update_mem);
    
    %% Windows table
    handles.tbl_windows.Data = cell(0, size(handles.tbl_windows.Data, 2));
    
    %% LaTeX
    set(0, 'defaulttextinterpreter', 'latex');
    
    %%
    guidata(hObject, handles);
    upgrade_calculus_table(hObject);
    
function upgrade_calculus_table(hObject)
    
    %% Create calculus
    if nargin == 0, hObject = gcbo;
    end
    all_data = guidata(hObject);
    all_data.calculus_info = load_calculus_config();
    empty_col = cell(length(all_data.calculus_info), 1);
    all_data.tbl_calculus.Data = {; ...
        all_data.calculus_info(:).full_name; ...
        empty_col{:}; ...
        empty_col{:}; ...
        empty_col{:}; ...
        empty_col{:}; ...
        empty_col{:}; ...
        empty_col{:}; ...
        empty_col{:}; ...
        empty_col{:}; ...
        all_data.calculus_info(:).name; ...
        }.';
    all_data.tbl_calculus_ids = [];
    guidata(hObject, all_data);
    
function update_memory_used(obj, event, la_memory_used)
    m = memory;
    la_memory_used.String = ['Memory used: ', get_byte_size(m.MemUsedMATLAB)];
    
    % --- Outputs from this function are returned to the command line.
function varargout = astro_form_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    % --------------------------------------------------------------------
function me_remove_project_Callback(hObject, eventdata, handles)
    % hObject    handle to me_remove_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_new_solution_Callback(hObject, eventdata, handles)
    % hObject    handle to me_new_solution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    [solution_name, path] = uiputfile('*', 'Choose directory and solution name');
    if isequal(solution_name, 0)
        return;
    end
    [~, solution_name, ~] = fileparts(solution_name);
    solution = create_solution(path, solution_name);
    if isempty(solution)
        return;
    end
    all_data.solution = solution;
    all_data.projects = [];
    update_projects_table(handles, all_data.projects);
    
    gui_open_solution(handles, solution);
    
    guidata(gcbo, all_data);
    
function gui_open_solution(handles, solution)
    handles.pa_main.Visible = 'On';
    handles.astro_form.Name = [solution.name, ' - Astrocyte Lab'];
    handles.pa_solution.Title = ['Solution: ', solution.name];
    
    handles.me_save_solution.Enable = 'On';
    handles.me_add_new_project.Enable = 'On';
    handles.me_add_existing_project.Enable = 'On';
    
function gui_close_solution(handles)
    handles.pa_main.Visible = 'Off';
    handles.astro_form.Name = 'Astrocyte Lab';
    handles.pa_solution.Title = 'Solution';
    
    handles.me_save_solution.Enable = 'Off';
    handles.me_add_new_project.Enable = 'Off';
    handles.me_add_existing_project.Enable = 'Off';
    
    % --------------------------------------------------------------------
function me_add_new_project_Callback(hObject, eventdata, handles)
    % hObject    handle to me_add_new_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    project = new_project_form;
    if isempty(project)
        return;
    end
    
    project = upgrade_calculus(project, all_data.solution);
    project = save_project(project, all_data.solution);
    project = load_project(project.project_dir, project.name, all_data.solution);
    
    if isempty(all_data.projects)
        all_data.projects = project;
        all_data.solution.projects_paths{1} = project.path;
    else
        all_data.projects(end + 1) = project;
        all_data.solution.projects_paths{end + 1} = project.path;
    end
    
    update_projects_table(handles, all_data.projects)
    
    guidata(gcbo, all_data);
    
function update_projects_table(handles, projects)
    data = cell(length(projects), 2);
    for i = 1:length(projects)
        data{i, 1} = projects(i).name;
        data{i, 2} = get_byte_size(projects(i).size);
    end
    handles.tbl_projects.Data = data;
    
    % --- Executes when selected cell(s) is changed in tbl_projects.
function tbl_projects_CellSelectionCallback(hObject, eventdata, handles)
    % hObject    handle to tbl_projects (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %    Indices: row and column indices of the cell(s) currently selecteds
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    ids = eventdata.Indices;
    if isempty(ids)
        data = {'Video path', ''; ...
            'Video size', ''; ...
            'Real video size', ''; ...
            'Project path', ''; ...
            'Project size', ''; ...
            'Memory used', ''; ...
            'Disk used', ''};
        handles.tbl_project.Data = data;
        handles.me_save_project.Enable = 'Off';
        handles.me_remove_project.Enable = 'Off';
        handles.me_move_project.Enable = 'Off';
        for i = 1:size(data, 1)
            data{i, 1} = ['<html><b>', data{i, 1}, '</b></html>'];
        end
        return;
    end
    
    handles.me_save_project.Enable = 'On';
    handles.me_remove_project.Enable = 'On';
    handles.me_move_project.Enable = 'On';
    
    id = ids(1);
    project = all_data.projects(id);
    solution = all_data.solution;
    data = {'Video path', project.astro_video_info.data_dir; ...
        'Video size', size_to_str(project.astro_video_info.size); ...
        'Real video size', size_to_str(project.astro_video_info.real_size); ...
        'Project path', build_path(project.path, solution); ...
        'Project size', get_byte_size(project.size); ...
        'Memory used', get_byte_size(project.memory_size); ...
        'Disk used', get_byte_size(project.disk_size); ...
        'Export folder', get_project_export_dir(project)};
    projects = all_data.projects;
    
    cnt = tabulate([ids(:, 1); length(projects) + 1].');
    cnt = num2cell(cnt(1:(end -1), 2));
    [projects.selected] = deal(cnt{:});
    
    all_data.projects = projects;
    
    for i = 1:size(data, 1)
        data{i, 1} = ['<html><b>', data{i, 1}, '</b></html>'];
    end
    
    handles.tbl_project.Data = data;
    
    preview = project.astro_video_info.preview;
    if size(preview, 3) == 3
        imshow(preview, 'Parent', handles.ax_preview);
    else
        imshow(preview, ...
            [min(preview(:)), max(preview(:))], ...
            'Parent', handles.ax_preview, 'Colormap', jet(255));
    end
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    tbl_calculus_CellSelectionCallback(handles.tbl_calculus, [], handles)
    
    % --- Executes when selected cell(s) is changed in tbl_calculus.
function tbl_calculus_CellSelectionCallback(hObject, eventdata, handles)
    % hObject    handle to tbl_calculus (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
    %    Indices: row and column indices of the cell(s) currently selecteds
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    %get(handles.tbl_calculus)
    if isa(eventdata, 'matlab.ui.eventdata.CellSelectionChangeData')
        ids = eventdata.Indices;
        all_data.tbl_calculus_ids = ids;
    else
        ids = all_data.tbl_calculus_ids;
    end
    if isempty(ids)
        handles.bu_calc.Enable = 'Off';
        handles.bu_save.Enable = 'Off';
        handles.bu_show.Enable = 'Off';
        handles.bu_hide.Enable = 'Off';
        handles.bu_close.Enable = 'Off';
        handles.bu_export_mat.Enable = 'Off';
        handles.bu_export_eps.Enable = 'Off';
        handles.bu_export_png.Enable = 'Off';
        handles.bu_export_csv.Enable = 'Off';
        guidata(gcbo, all_data);
        return;
    end
    
    handles.bu_show.Enable = 'On';
    handles.bu_calc.Enable = 'On';
    handles.bu_export_csv.Enable = 'On';
    handles.bu_export_mat.Enable = 'On';
    handles.bu_export_png.Enable = 'On';
    handles.bu_export_eps.Enable = 'On';
    
    projects = all_data.projects;
    
    data = handles.tbl_calculus.Data;
    
    cnt = tabulate([ids(:, 1); size(data, 1) + 1].');
    cnt = num2cell(cnt(1:(end -1), 2));
    
    for i = 1:length(projects)
        if ~projects(i).selected
            continue;
        end
        for j = 1:length(cnt)
            projects(i).calculus_info(j).is_selected = cnt{j};
        end
    end
    
    handles.tbl_calculus.Data = data;
    all_data.projects = projects;
    
    guidata(gcbo, all_data);
    
function update_calculus_table(handles, projects)
    all_data = guidata(gcbo);
    data = handles.tbl_calculus.Data;
    
    id_algo = get_selected_algo(handles);
    calculus_info = all_data.calculus_info;
    for j = 1:length(calculus_info)
        is_calculated = [0, 0; 0, 0];
        is_exported = [0, 0; 0, 0];
        is_showed = [0, 0; 0, 0];
        is_valid = [0, 0; 0, 0];
        calculate_start_time = [NaT, NaT];
        calculate_finish_time = [NaT, NaT];
        for i = 1:length(projects)
            project = projects(i);
            cur_calculus_info = project.calculus_info(j);
            if project.selected
                is_calculated = upd_array(is_calculated, cur_calculus_info.is_calculated);
                is_exported = upd_array(is_exported, cur_calculus_info.is_exported);
                is_showed = upd_array(is_showed, cur_calculus_info.is_showed);
                is_valid = upd_array(is_valid, cur_calculus_info.is_valid);
                if ~isnat(cur_calculus_info.calculate_start_time)
                    calculate_start_time = min( ...
                        cur_calculus_info.calculate_start_time, ...
                        calculate_start_time);
                end
                if ~isnat(cur_calculus_info.calculate_finish_time)
                    calculate_finish_time = max( ...
                        cur_calculus_info.calculate_finish_time, ...
                        calculate_finish_time);
                end
            end
        end
        is_calculated = max(is_calculated(id_algo, :), [], 1);
        is_exported = max(is_exported(id_algo, :), [], 1);
        is_showed = max(is_showed(id_algo, :), [], 1);
        is_valid = max(is_valid(id_algo, :), [], 1);
        calculate_start_time = min(calculate_start_time(id_algo));
        calculate_finish_time = max(calculate_finish_time(id_algo));
        if is_calculated(1) + is_calculated(2) <= 1
            if is_calculated(2)
                if is_valid(1)
                    data{j, 2} = 'Need recalc';
                else
                    data{j, 2} = 'Yes';
                end
            else
                data{j, 2} = 'No';
            end
        else
            data{j, 2} = 'Multiple';
        end
        
        if is_exported(1) + is_exported(2) <= 1
            if is_exported(2)
                data{j, 3} = 'Yes';
            else
                data{j, 3} = 'No';
            end
        else
            data{j, 3} = 'Multiple';
        end
        
        if is_showed(1) + is_showed(2) <= 1
            if is_showed(2)
                data{j, 4} = 'Yes';
            else
                data{j, 4} = 'No';
            end
        else
            data{j, 4} = 'Multiple';
        end
        if ~isnat(calculate_start_time)
            data{j, 6} = datestr(calculate_start_time);
        else
            data{j, 6} = '';
        end
        if ~isnat(calculate_finish_time)
            data{j, 7} = datestr(calculate_finish_time);
        else
            data{j, 7} = '';
        end
        if ~isnat(calculate_start_time) && ~isnat(calculate_finish_time)
            elapsed_time = calculate_finish_time - calculate_start_time;
            data{j, 8} = char(duration(elapsed_time, 'Format', 'dd:hh:mm:ss'));
        else
            data{j, 8} = '';
        end
    end
    handles.tbl_calculus.Data = data;
    
function [cnt] = upd_array(cnt, val)
    for i = 1:length(val)
        cnt(i, val(i) + 1) = 1;
    end
    
function update_windows(handles, map_figures)
    data = cell(0, size(handles.tbl_windows.Data, 2));
    uuid_figures = map_figures.keys;
    val_figures = map_figures.values;
    for i = 1:length(uuid_figures)
        name = uuid_figures{i};
        name = strsplit(name, char(31));
        [project_name, calculus_name] = name{:};
        id_figures = val_figures{i}.keys;
        figures = val_figures{i}.values;
        for j = 1:length(id_figures)
            if ~isvalid(figures{j}), continue;
            end
            is_visible = get(figures{j}, 'Visible');
            data = [data; { ...
                project_name, ...
                calculus_name, ...
                id_figures{j}, ...
                is_visible, ...
                ''}];
        end
    end
    handles.tbl_windows.Data = data;
    
    % --------------------------------------------------------------------
function me_save_project_Callback(hObject, eventdata, handles)
    % hObject    handle to me_save_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    solution = all_data.solution;
    projects = all_data.projects;
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'save'));
    
    update_projects_table(handles, projects);
    
    all_data.projects = projects;
    guidata(gcbo, all_data);
    
    % --------------------------------------------------------------------
function me_save_solution_Callback(hObject, eventdata, handles)
    % hObject    handle to me_save_solution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    solution = all_data.solution;
    projects = all_data.projects;
    save_solution(solution);
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 0, ...
        'project_action', 'save'));
    
    update_projects_table(handles, projects);
    
    all_data.projects = projects;
    guidata(gcbo, all_data);
    
    % --------------------------------------------------------------------
function me_open_solution_Callback(hObject, eventdata, handles)
    % hObject    handle to me_open_solution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~form_unload_solution(handles)
        return;
    end
    
    all_data = guidata(gcbo);
    [solution_name, solution_dir] = uigetfile('*', 'Select solution file');
    if isequal(solution_name, 0)
        return;
    end
    [~, solution_name, ~] = fileparts(solution_name);
    solution = load_solution(solution_dir, solution_name);
    if isempty(solution)
        return;
    end
    
    projects = [];
    for i = 1:length(solution.projects_paths)
        project_path = solution.projects_paths{i};
        [project_dir, project_name] = fileparts(project_path);
        project = load_project(project_dir, project_name, solution);
        if isempty(project)
            continue;
        end
        project = upgrade_calculus(project, solution);
        if isempty(projects)
            projects = project;
        else
            projects(end + 1) = project;
        end
        update_projects_table(handles, projects)
    end
    
    update_projects_table(handles, projects)
    
    gui_open_solution(handles, solution);
    
    all_data.projects = projects;
    all_data.solution = solution;
    
    guidata(gcbo, all_data);
    
function me_upgrade_projects_Callback(hObject, eventdata, handles)
    % hObject    handle to me_upgrade_projects (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    upgrade_calculus_table();
    all_data = guidata(gcbo);
    solution = all_data.solution;
    projects = all_data.projects;
    
    for i = 1:length(projects)
        project = projects(i);
        project = upgrade_calculus(project, solution);
        project = upgrade_project(project);
        projects = upd_struct(project, projects, i);
    end
    
    update_calculus_table(handles, projects);
    
    all_data.projects = projects;
    all_data.solution = solution;
    
    guidata(gcbo, all_data);
    
    add_info_log('Projects upgraded successfully');
    
function me_add_existing_project_Callback(hObject, eventdata, handles)
    % hObject    handle to me_add_existing_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    solution = all_data.solution;
    
    [project_name, project_dir] = uigetfile('*', 'Select project file');
    if isequal(project_name, 0)
        return;
    end
    [~, project_name, ~] = fileparts(project_name);
    
    project = load_project(project_dir, project_name, solution);
    if isempty(project)
        return;
    end
    
    projects = all_data.projects;
    
    if isempty(projects)
        projects = project;
        solution.projects_paths{1} = project.path;
    else
        projects(end + 1) = project;
        solution.projects_paths{end + 1} = project.path;
    end
    update_projects_table(handles, projects)
    
    all_data.projects = projects;
    all_data.solution = solution;
    
    guidata(gcbo, all_data);
    
function update_progress(handles, x)
    if x == -1
        set(get(handles.ax_progress, 'Children'), 'Visible', 'Off');
    else
        set(get(handles.ax_progress, 'Children'), 'Visible', 'On');
        uiProgressBar(handles.ax_progress, x);
    end
    
    % % --------------------------------------------------------------------
    % function me_move_project_Callback(hObject, eventdata, handles)
    % % hObject    handle to me_move_project (see GCBO)
    % % eventdata  reserved - to be defined in a future version of MATLAB
    % % handles    structure with handles and user data (see GUIDATA)
    %
    
    % --------------------------------------------------------------------
function me_add_project_Callback(hObject, eventdata, handles)
    % hObject    handle to me_add_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_solution_Callback(hObject, eventdata, handles)
    % hObject    handle to me_solution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
function id_algo = get_selected_algo(handles)
    id_algo = [];
    if handles.rb_itmm_algo.Value, id_algo = [id_algo, 1];
    end
    if handles.rb_yu_wei_algo.Value, id_algo = [id_algo, 2];
    end
    if handles.rb_compare_algorithms.Value, id_algo = [1, 2];
    end
    
    % --- Executes on button press in bu_calc.
function bu_calc_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_calc (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    projects = all_data.projects;
    solution = all_data.solution;
    
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'calculuses', ...
        'selected_calculus', 1, ...
        'calculus_action', 'calc', ...
        'id_algorithm', get_selected_algo(handles)));
    
    update_calculus_table(handles, projects);
    
    all_data.projects = projects;
    all_data.solution = solution;
    
    guidata(gcbo, all_data);
    
    % --- Executes on button press in bu_save_calculus.
function bu_save_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_save_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_show_calculus.
function bu_show_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_show_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_hide_calculus.
function bu_hide_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_hide_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_export.
function bu_export_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_export (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to me_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_calc_Callback(hObject, eventdata, handles)
    % hObject    handle to me_calc (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_save_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to me_save_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_show_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to me_show_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_hide_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to me_hide_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_export_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to me_export_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_show_window.
function bu_show_window_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_show_window (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_hide_window.
function bu_hide_window_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_hide_window (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_calc_calculus.
function bu_calc_calculus_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_calc_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_export_mat.
function bu_export_mat_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_export_mat (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    projects = all_data.projects;
    solution = all_data.solution;
    
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'calculuses', ...
        'selected_calculus', 1, ...
        'calculus_action', 'save', ...
        'save_type', 'mat', ...
        'id_algorithm', get_selected_algo(handles)));
    
    all_data.projects = projects;
    all_data.solution = solution;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in bu_export_eps.
function bu_export_eps_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_export_eps (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    projects = all_data.projects;
    solution = all_data.solution;
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'calculuses', ...
        'selected_calculus', 1, ...
        'calculus_action', 'save', ...
        'save_type', 'eps', ...
        'id_algorithm', get_selected_algo(handles)));
    
    all_data.projects = projects;
    all_data.solution = solution;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in bu_export_png.
function bu_export_png_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_export_png (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    projects = all_data.projects;
    solution = all_data.solution;
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'calculuses', ...
        'selected_calculus', 1, ...
        'calculus_action', 'save', ...
        'save_type', 'png', ...
        'id_algorithm', get_selected_algo(handles)));
    
    all_data.projects = projects;
    all_data.solution = solution;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in bu_export_csv.
function bu_export_csv_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_export_csv (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    all_data = guidata(gcbo);
    projects = all_data.projects;
    solution = all_data.solution;
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'calculuses', ...
        'selected_calculus', 1, ...
        'calculus_action', 'save', ...
        'save_type', 'csv', ...
        'id_algorithm', get_selected_algo(handles)));
    
    all_data.projects = projects;
    all_data.solution = solution;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in bu_close_window.
function bu_close_window_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_close_window (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_show.
function bu_show_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_show (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    projects = all_data.projects;
    solution = all_data.solution;
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'calculuses', ...
        'selected_calculus', 1, ...
        'calculus_action', 'show', ...
        'id_algorithm', get_selected_algo(handles)));
    
    all_data.projects = projects;
    all_data.solution = solution;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in bu_hide.
function bu_hide_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_hide (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_close.
function bu_close_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_close (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on button press in bu_save.
function bu_save_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_save (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --------------------------------------------------------------------
function me_project_Callback(hObject, eventdata, handles)
    % hObject    handle to me_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes during object creation, after setting all properties.
function pa_calculus_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to pa_calculus (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % --------------------------------------------------------------------
function mec_project_Callback(hObject, eventdata, handles)
    % hObject    handle to mec_project (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes when astro_form is resized.
function astro_form_SizeChangedFcn(hObject, eventdata, handles)
    % hObject    handle to astro_form (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
    % hObject    handle to listbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from listbox1
    
    % --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to listbox1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject, 'BackgroundColor'), get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end
    
    % --- Executes when user attempts to close astro_form.
function astro_form_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to astro_form (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: delete(hObject) closes the figure
    if ~form_unload_solution(handles)
        return;
    end
    clear_figures;
    stop(handles.tm_update_mem);
    delete(handles.tm_update_mem);
    delete(hObject);
    
    % --- Executes on button press in bu_export_avi.
function bu_export_avi_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_export_avi (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    projects = all_data.projects;
    solution = all_data.solution;
    projects = traverse_projects(projects, ...
        struct('solution', solution, 'selected_projects', 1, ...
        'project_action', 'calculuses', ...
        'selected_calculus', 1, ...
        'calculus_action', 'save', ...
        'save_type', 'avi', ...
        'id_algorithm', get_selected_algo(handles)));
    
    all_data.projects = projects;
    all_data.solution = solution;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in rb_itmm_algo.
function rb_itmm_algo_Callback(hObject, eventdata, handles)
    % hObject    handle to rb_itmm_algo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of rb_itmm_algo
    all_data = guidata(gcbo);
    projects = all_data.projects;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in rb_yu_wei_algo.
function rb_yu_wei_algo_Callback(hObject, eventdata, handles)
    % hObject    handle to rb_yu_wei_algo (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of rb_yu_wei_algo
    all_data = guidata(gcbo);
    projects = all_data.projects;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
    % --- Executes on button press in rb_compare_algorithms.
function rb_compare_algorithms_Callback(hObject, eventdata, handles)
    % hObject    handle to rb_compare_algorithms (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of rb_compare_algorithms
    all_data = guidata(gcbo);
    projects = all_data.projects;
    update_calculus_table(handles, projects);
    guidata(gcbo, all_data);
    
function choice = form_unload_solution(handles)
    all_data = guidata(gcbo);
    if ~isfield(all_data, 'solution') || isempty(all_data.solution)
        choice = true;
        return;
    end
    answers = {'Save solution and all projects'; ...
        'Save solution and ask for projects'; ...
        'Discard changes'};
    choice = questdlg('Save solution?', 'Save...', ...
        answers{1}, answers{2}, answers{3}, answers{1});
    if isempty(choice)
        choice = false;
        return;
    end
    repchoice = answers;
    repchoice(:) = {choice};
    choice = find(cellfun(@strcmp, answers, repchoice));
    is_save_solution = choice < 3;
    is_save_all_projects = choice == 1;
    is_ask_save_project = choice == 2;
    
    projects = all_data.projects;
    for i = length(projects):-1:1
        if is_ask_save_project
            choice = form_unload_project(projects(i).name);
        else
            choice = is_save_all_projects;
        end
        if choice
            projects(i) = save_project(projects(i), all_data.solution);
        end
        add_info_log(['Unload project ', projects(i).name]);
        projects = unload_project(projects, i, all_data.solution);
        update_projects_table(handles, projects);
    end
    if is_save_solution
        save_solution(all_data.solution);
    end
    all_data.projects = projects;
    all_data.solution = [];
    update_projects_table(handles, projects);
    guidata(gcbo, all_data);
    choice = true;
    
function choice = form_unload_project(project_name)
    answers = {'Save project', 'Discard changes'};
    choice = questdlg(['Save project ', project_name, ' ?'], ...
        'Save...', answers{1}, answers{2}, answers{1});
    repchoice = answers;
    repchoice(:) = {choice};
    choice = find(cellfun(@strcmp, answers, repchoice)) == 1;
    
    % --- Executes on button press in cb_follow_log.
function cb_follow_log_Callback(hObject, eventdata, handles)
    % hObject    handle to cb_follow_log (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of cb_follow_log
    
    % --- Executes on button press in bu_open_export_dir.
function bu_open_export_dir_Callback(hObject, eventdata, handles)
    % hObject    handle to bu_open_export_dir (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    all_data = guidata(gcbo);
    projects = all_data.projects;
    for i = 1:length(projects)
        if projects(i).selected
            export_dir = get_project_export_dir(projects(i));
            if exist(export_dir, 'dir') ~= 7
                mkdir(export_dir);
            end
            try
                winopen(export_dir);
                add_info_log(['Export folder ', export_dir, ' opened.'])
            catch
                add_info_log(['Can not open export folder ', export_dir])
            end
        end
    end
