function load_info_log(info_log_data_)
    global info_log_data
    info_log_data = {};
    
    h_astro_form = findobj('Tag', 'astro_form');
    
    if ~isempty(h_astro_form)
        handles = guidata(h_astro_form);
        astro_form('update_progress', handles, -1);
        info_log_data = info_log_data_;
        set(handles.li_log, 'String', info_log_data_);
        if ~isempty(info_log_data)
            set(handles.li_log, 'Value', length(info_log_data_));
            set(handles.li_log, 'ListboxTop', length(info_log_data_));
        end
        set(handles.la_status, 'String', 'Ready.');
    end
    
    if ~isempty(h_astro_form)
        handles = guidata(h_astro_form);
    end
end