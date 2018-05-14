function fig = get_figure(name, id, varargin)
    global all_figs
    if isempty(all_figs)
        all_figs = containers.Map();
    end
    names = strsplit(name, char(31));
    varargin = [varargin, ...
        {'CloseRequestFcn', {@(src, event, name, id) close_figure(name, id), name, id}, ...
        'Color', [237, 242, 242] / 255.0, ...
        'Name', ['Project: ', names{1}, ' | Calculus: ', names{2}], ...
        'NumberTitle', 'off'}];
    if all_figs.isKey(name)
        figs = all_figs(name);
        fig = [];
        if figs.isKey(id)
            fig = figs(id);
            if length(varargin) < 2 || ~(strcmp(varargin{1}, 'Visible') && ...
                    strcmp(varargin{2}, 'Off'))
                figure(fig);
            end
        end
        if isempty(fig) || ~isvalid(fig)
            fig = figure(varargin{:});
            figs(id) = fig;
        end
        all_figs(name) = figs;
    else
        fig = figure(varargin{:});
        all_figs(name) = containers.Map({id}, {fig});
    end
    
    set(groot, 'CurrentFigure', fig);
    
    h_astro_form = findobj('Tag', 'astro_form');
    if ~isempty(h_astro_form)
        handles = guidata(h_astro_form);
        astro_form('update_windows', handles, all_figs);
    end
end
