function close_figure(name, id)
    global all_figs
    if isempty(all_figs)
        all_figs = containers.Map();
    end
    if all_figs.isKey(name)
        figs = all_figs(name);
        if figs.isKey(id)
            fig = figs(id);
            delete(fig);
            figs.remove(id);
        end
        if figs.Count == 0
            all_figs.remove(name);
        else
            all_figs(name) = figs;
        end
    end
    
    h_astro_form = findobj('Tag', 'astro_form');
    if ~isempty(h_astro_form)
        handles = guidata(h_astro_form);
        astro_form('update_windows', handles, all_figs);
    end
end