function [fig] = plot_heatmap(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Painting ', properties.full_name, '...']);
    end
    
    id_algo = properties.id_algorithm;
    if isempty(id_algo)
        id_algo = [1];
    end
    
    %% Loading data
    ids = get_ids(properties, calculus, id_algo);
    if ~isempty(whos(calculus, properties.variable))
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    rescale_info = rescale_variable(calculus, properties);
    
    %% Load data
    ticks = calculus.ticks;
    ticks.width = ticks.width * rescale_info.new_coef(1);
    ticks.height = ticks.height * rescale_info.new_coef(2);
    
    %% Paint
    number_fig = 0;
    for id = ids
        if iscell(variables)
            if has_item(calculus, properties.variable, id, false)
                variable = variables{id{:}};
            else
                continue
            end
        else
            variable = variables;
        end
        if isempty(properties.id_algorithm)
            prefix = '';
        else
            if id{2} == 1
                prefix = ' (ITMM)';
            else if id{2} == 2
                    prefix = ' (Yu Wei)';
                end
            end
        end
        name = [properties.title{1}, prefix];
        if isfield(properties, 'visible') && properties.visible == 0
            fig = get_figure(properties.uuid_figure, number_fig, 'Visible', 'Off');
        else
            fig = get_figure(properties.uuid_figure, number_fig);
        end
        number_fig = number_fig + 1;
        clf(fig);
        ax = axes(fig);
        surf(ax, ticks.width, ticks.height, rescale_info.new_coef(3) * variable, ...
            'LineStyle', 'none', 'FaceColor', 'flat', 'DisplayName', name); ...
            view(ax, 2);
        if properties.is_colorbar
            colormap(fig, jet(1000));
            c = colorbar(ax);
            c.Label.String = rescale_info.new_units{3};
        end
        axis equal;
        ax.YDir = 'Reverse';
        xlim(ax, [0, max(ticks.width)]);
        ylim(ax, [0, max(ticks.height)]);
        xlabel(ax, [properties.x_label{1}, ' ', rescale_info.new_units{1}]);
        ylabel(ax, [properties.y_label{1}, ' ', rescale_info.new_units{2}]);
        title(ax, name);
        pretty_fig(fig);
    end
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' painteed.']);
    end
end
