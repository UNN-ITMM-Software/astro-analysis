% Only sequential code
function [] = add_info_log(message, progress, add_time, is_drawnow)
    global info_log_data logging_enabled
    persistent prev_messsage prev_is_progress h_astro_form last_update
    persistent begin_progress
    
    if isempty(logging_enabled)
        logging_enabled = true;
    end
    if ~logging_enabled
        return;
    end
    
    if isempty(prev_is_progress)
        prev_is_progress = false;
    end
    if isempty(prev_messsage)
        prev_messsage = '';
    end
    if nargin < 4 || isempty(is_drawnow)
        is_drawnow = true;
    end
    if nargin < 3 || isempty(add_time)
        add_time = true;
    end
    if add_time
        fmt_message = sprintf('%s | %s', datestr(now), message);
    else
        fmt_message = message;
    end
    is_progress = 0;
    if nargin > 1 && ~isempty(progress)
        if ~prev_is_progress
            begin_progress = clock;
        end
        is_progress = 1;
        progress_percent = int32(100 * progress);
        if progress > 0
            add = floor(etime(clock, begin_progress) / progress);
            approx = datetime(begin_progress) + duration(0, 0, add);
        else
            approx = begin_progress;
        end
        fmt_message = sprintf('%s | %3d%% | Approx. finish: %s', ...
            fmt_message, progress_percent, datestr(approx));
    end
    
    if isempty(last_update)
        last_update = clock;
    end
    
    %     if is_drawnow
    %         dif = etime(clock, last_update);
    %         is_drawnow = dif > 1;
    %     end
    
    if isempty(h_astro_form) || ~isvalid(h_astro_form)
        h_astro_form = findobj('Tag', 'astro_form');
    end
    
    if is_progress && prev_is_progress && ~isempty(info_log_data)
        info_log_data{end} = fmt_message;
    else
        info_log_data{end + 1} = fmt_message;
    end
    
    if isempty(h_astro_form)
        if is_progress && prev_is_progress
            fprintf(repmat('\b', 1, numel(prev_messsage) + 1));
        end
        fprintf('%s\n', fmt_message);
    else
        handles = guidata(h_astro_form);
        log_list_old = get(handles.li_log, 'String');
        log_list = info_log_data;
        
        if is_progress
            astro_form('update_progress', handles, progress);
        else
            astro_form('update_progress', handles, -1);
        end
        
        id = get(handles.li_log, 'Value');
        id = min(id, length(log_list_old));
        
        if is_drawnow
            set(handles.li_log, 'String', log_list);
            if handles.cb_follow_log.Value == 1
                set(handles.li_log, 'ListboxTop', length(log_list));
                set(handles.li_log, 'Value', length(log_list));
            end
        end
        set(handles.la_status, 'String', fmt_message);
    end
    
    prev_messsage = fmt_message;
    prev_is_progress = is_progress;
    if is_drawnow
        drawnow('limitrate');
        last_update = clock;
    end
end