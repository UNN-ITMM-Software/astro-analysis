function [fig] = plot_per_frame(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Painting ', properties.full_name, '...']);
    end
    
    %% Properties
    id_algo = properties.id_algorithm;
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, 0, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, 0);
    end
    rescale_info = rescale_variable(calculus, properties);
    ticks = calculus.ticks;
    ticks.time = ticks.time * rescale_info.new_coef(1);
    nt = length(ticks.time);
    frames_range = properties.frames_range;
    time = [max(1, frames_range(1)), min(frames_range(2), nt)];
    all_h = [];
    ids = get_ids(properties, calculus, id_algo);
    
    %% Load data
    if ~isempty(whos(calculus, properties.variable))
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    
    %% Painting
    clf(fig);
    ax = axes(fig);
    if properties.is_colorbar
        cmap = cool(size(calculus.events_info, 1));
        c = colorbar(ax);
        ylabel(c, ['$', properties.colorbar_label{1}, '$'], 'Interpreter', 'latex', 'Rotation', 0);
        colormap(cmap);
        caxis(min_max(calculus.thresholds));
    end
    for id = ids
        if has_item(calculus, properties.variable, id, false)
            variable = variables{id{:}};
        else
            continue
        end
        if id{2} == 1
            prefix = '(ITMM)';
            color = [0.5, 0, 0];
            if id{1} > 1, color = cmap(id{1}, :);
            end
        else if id{2} == 2
                prefix = '(Yu Wei)';
                color = [1.0, 0.7, 0];
            end
        end
        name = [properties.title{1}, ' ', prefix];
        if length(id_algo) == 2
            name = [properties.title{1}, ' (Yu Wei) and (ITMM)'];
        end
        hold on
        h = plot(ax, ticks.time(time(1):time(2)), ...
            rescale_info.new_coef(2) * variable(time(1):time(2)), ...
            'LineWidth', 3, 'Color', color);
        if id{1} == 1
            h.DisplayName = prefix;
            all_h = [all_h, h];
        end
        xlim(ax, [ticks.time(time(1)), ticks.time(time(2))]);
        xlabel(ax, [properties.x_label{1}, ' ', rescale_info.new_units{1}]);
        ylabel(ax, [properties.y_label{1}, ' ', rescale_info.new_units{2}]);
        title(ax, name);
        legend(all_h, 'Location', 'best');
        %legend(ax, '-DynamicLegend');
        pretty_fig(fig);
    end
    
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' painteed.']);
    end
end
