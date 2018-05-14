function [fig] = plot_statistics(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Painting statistics...');
    end
    
    %% Properties
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, 0, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, 0);
    end
    id_distr = properties.id_distr;
    id_algos = properties.id_algorithm;
    
    %% Painting
    clf(fig);
    ax = axes(fig);
    ids = get_ids(properties, calculus, id_algos);
    ids = fliplr(ids);
    rescale_info = rescale_variable(calculus, properties);
    if properties.is_colorbar
        cmap = cool(size(calculus.events_info, 1));
        c = colorbar(ax);
        ylabel(c, ['$', properties.colorbar_label{1}, '$'], 'Interpreter', 'latex', 'Rotation', 0);
        colormap(cmap);
        caxis(min_max(calculus.thresholds));
    end
    hold on;
    all_h = [];
    for id = ids
        
        %% Load data
        id_algo = id{2};
        if ~has_item(calculus, 'events_stat', id, true)
            continue;
        end
        events_stat = calculus.events_stat(id{:});
        if id_algo == 1
            prefix = '(ITMM)';
            if id{1} == 1
                ccdf_color = [0.5, 0, 0];
            else
                ccdf_color = cmap(id{1}, :);
            end
        elseif id_algo == 2
            prefix = '(Yu Wei)';
            ccdf_color = [1.0, 0.7, 0];
        end
        
        %% Painting
        if id_distr == 1
            stat = events_stat.durations;
        else
            
            stat = events_stat.max_projections;
        end
        if isempty(stat.ccdf)
            continue;
        end
        stat.ccdf(:, 1) = stat.ccdf(:, 1) * rescale_info.new_coef(1);
        stat.ccdf(:, 2) = stat.ccdf(:, 2) * rescale_info.new_coef(2);
        h = plot(ax, stat.ccdf(:, 1), stat.ccdf(:, 2), 'Color', ccdf_color, ...
            'LineWidth', 3, 'DisplayName', sprintf('%s', prefix));
        
        lim = axis(ax);
        lim_new = [min(stat.ccdf(:, 1)), max(stat.ccdf(:, 1)), min(stat.ccdf(:, 2)), 1.0];
        axis(ax, [min(lim(1), lim_new(1)), max(lim(2), lim_new(2)), ...
            min(lim(3), lim_new(3)), max(lim(4), lim_new(4))]);
        
        if id{1} == 1
            all_h = [all_h, h];
        end
    end
    
    xlogscale(ax);
    ylogscale(ax);
    
    xlabel(ax, [properties.x_label{1}, ' ', rescale_info.new_units{1}]);
    ylabel(ax, [properties.y_label{1}, ' ', rescale_info.new_units{2}]);
    name = properties.title{1};
    title(ax, name);
    
    legend(all_h);
    pretty_fig(fig);
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Statistics painted.');
    end
end
