function [fig] = plot_statistics_compare(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Painting statistics compare...');
    end
    
    %% Properties
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, 0, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, 0);
    end
    id_distr = properties.id_distr;
    id_algos = properties.id_algorithm;
    
    %% Preparing
    dthr = calculus.thresholds(1, end) / length(calculus.thresholds);
    x = repmat([-2 * dthr, -dthr, calculus.thresholds].', 1, 2);
    y = zeros(size(x));
    y_neg = y;
    y_pos = y;
    dx = 0.05 * (x(end) - x(1));
    
    %% Painting
    clf(fig);
    ax = [subplot(2, 1, 1, 'Parent', fig), subplot(2, 1, 2, 'Parent', fig)];
    s = {};
    ids = get_ids(properties, calculus, id_algos);
    cmap = [0.5, 0, 0; cool(size(calculus.events_info, 1))];
    for cur_ax = ax
        c = colorbar(cur_ax);
        ylabel(c, ['$', properties.colorbar_label{1}, '$'], 'Interpreter', 'latex', 'Rotation', 0);
        colormap(cmap);
        caxis(cur_ax, min_max(calculus.thresholds));
        xlim(cur_ax, [x(1) - dx, x(end) + dx]);
        hold(cur_ax, 'on');
    end
    rescale_info = rescale_variable(calculus, properties);
    all_h = [];
    k = 0;
    for id = ids
        
        %% Load data
        id_algo = id{2};
        if ~all([id{:}] <= size(calculus.events_stat))
            continue;
        end
        events_stat = calculus.events_stat(id{:});
        events_info = calculus.events_info(id{:});
        if isempty(events_info.number)
            continue;
        end
        
        %% Painting
        if id_algo == 1
            name = '(ITMM)';
            ccdf_color = cmap(id{1}, :);
        elseif id_algo == 2
            name = '(Yu Wei)';
            ccdf_color = [1, 0.7, 0];
        end
        if id_distr == 1
            stat = events_stat.durations;
        else
            stat = events_stat.max_projections;
        end
        if isempty(stat) || isempty(stat.ccdf)
            continue;
        end
        
        if id{1} == 1
            ind = id{1} + id{2} - 1;
        else
            ind = id{1} + 1;
        end
        
        y(ind) = stat.alpha.value;
        y_neg(ind) = stat.alpha.ints(1);
        y_pos(ind) = stat.alpha.ints(2);
        
        plot(ax(1), [x(ind); x(ind)], [y_neg(ind); y_pos(ind)], ...
            '-', 'LineWidth', 3, 'Color', ccdf_color);
        h = plot(ax(1), x(ind), y(ind), '*', 'LineWidth', 5, ...
            'Color', ccdf_color);
        if id{1} == 1
            h.DisplayName = ['$\alpha$ for ', name];
            all_h = [all_h, h];
        end
        
        plot(ax(2), x(ind), stat.stats.rs, '*', 'LineWidth', 10, ...
            'Color', ccdf_color);
        k = k + 1;
        add_info_log('Painting statistics compare...', double(k) / length(ids));
    end
    
    plot(ax(1), [x(1, 1), x(end, 1)], [mean(y(y > 0)), mean(y(y > 0))], '--', 'LineWidth', 4, 'Color', [4, 148, 1] / 255.0, ...
        'DisplayName', '$\alpha$ mean for cells');
    
    xlabel(ax(1), [properties.x_label{1}, ' ', rescale_info.new_units{1}]);
    ylabel(ax(1), sprintf('$\\alpha$ for %s', [properties.y_label{1}, ' ', rescale_info.new_units{2}]));
    
    legend(ax(1), all_h);
    
    title(ax(1), properties.title);
    
    xlabel(ax(2), [properties.x_label{2}, ' ', properties.x_unit{2}]);
    ylabel(ax(2), ['$', properties.y_label{2}, '$']);
    
    for cur_ax = ax
        hold(cur_ax, 'off');
    end
    
    pretty_fig(fig);
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Statistics compare painted.');
    end
end
