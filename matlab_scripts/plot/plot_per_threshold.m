function [fig] = plot_per_threshold(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Painting ', properties.full_name, '...']);
    end
    
    %% Properties
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, 0, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, 0);
    end
    id_algos = properties.id_algorithm;
    
    if is_created(calculus, properties.variable)
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    ids = get_ids(properties, calculus, id_algos);
    
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
    rescale_info = rescale_variable(calculus, properties);
    dthr = calculus.thresholds(1, end) / length(calculus.thresholds);
    x = repmat([-2 * dthr, -dthr, calculus.thresholds].', 1, 2);
    y = zeros(size(x));
    y_neg = y;
    dx = 0.05 * (x(end) - x(1));
    xlim([x(1) - dx, x(end) + dx]);
    all_h = [];
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
        name = properties.title{1};
        
        if id{1} == 1
            ind = id{1} + id{2} - 1;
        else
            ind = id{1} + 1;
        end
        y(ind) = variable;
        hold on;
        if isequal(properties.plot_type{1}, 'y(x)+alpha')
            shannon_entropy_mean_alpha = calculus.shannon_entropy_mean_alpha;
            y_neg(ind) = rescale_info.new_coef(2) * max(0, y(ind) - shannon_entropy_mean_alpha{id{:}});
            y_pos(ind) = rescale_info.new_coef(2) * y(ind) + shannon_entropy_mean_alpha{id{:}};
            h = plot([x(ind); x(ind)], [y_neg(ind); y_pos(ind)], '-', 'LineWidth', 3, ...
                'Color', color);
        end
        h = plot(x(ind), rescale_info.new_coef(2) * y(ind), '*', 'LineWidth', 5, ...
            'Color', color);
        
        if id{1} == 1
            h.DisplayName = prefix;
            all_h = [all_h, h];
        end
    end
    
    hold off;
    xlabel(ax, [properties.x_label{1}, ' ', rescale_info.new_units{1}]);
    ylabel(ax, [properties.y_label{1}, ' ', rescale_info.new_units{2}])
    legend(all_h, 'Location', 'best');
    title(name);
    
    pretty_fig(fig);
    
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' painteed.']);
    end
end
