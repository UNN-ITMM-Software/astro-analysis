function [] = info_log(message)
fmt_message = sprintf('%s | %s ', datestr(now), message);
if isempty(gcbo) 
    disp (fmt_message)
else
    handles = guidata(gcbo);
    log_list = get(handles.li_log,'String');
    log_list{end + 1} = fmt_message;
    set(handles.li_log,'String', log_list);
end 
drawnow;