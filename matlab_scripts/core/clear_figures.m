function [] = clear_figures()
    global all_figs
    if isempty(all_figs)
        all_figs = containers.Map();
    end
    keys_figs = all_figs.keys;
    values_figs = all_figs.values;
    for i = 1:length(keys_figs)
        figures = values_figs{i}.values;
        figures = [figures{:}];
        figures = figures(isvalid(figures));
        delete(figures);
    end
    all_figs = containers.Map();
    
    h_astro_form = findobj('Tag', 'astro_form');
    if ~isempty(h_astro_form)
        handles = guidata(h_astro_form);
        astro_form('update_windows', handles, all_figs);
    end
end