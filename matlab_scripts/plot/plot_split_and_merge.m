function [fig] = plot_split_and_merge(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Painting number of splits, number of mergers and number of regions per frame...');
    end
    
    %% Properties
    id_algo = properties.id_algorithm;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Loading data
    if ~isempty(whos(calculus, 'count_merge_per_frame'))
        count_merge_per_frame_cell = calculus.count_merge_per_frame;
    else
        add_info_log('count_merge_per_frame not found');
        return
    end
    if ~isempty(whos(calculus, 'count_split_per_frame'))
        count_split_per_frame_cell = calculus.count_split_per_frame;
    else
        add_info_log('count_split_per_frame not found');
        return
    end
    if ~isempty(whos(calculus, 'count_regions'))
        count_regions_cell = calculus.count_regions;
    else
        add_info_log('count_regions not found');
        return
    end
    rescale_info = rescale_variable(calculus, properties);
    ticks = calculus.ticks;
    ticks.time = ticks.time * rescale_info.new_coef(1);
    nt = length(ticks.time);
    frames_range = properties.frames_range;
    time = [max(1, frames_range(1)), min(frames_range(2), nt)];
    
    %% Painting
    number_fig = 0;
    for id = ids
        if has_item(calculus, 'count_merge_per_frame', id, false)
            count_merge_per_frame = count_merge_per_frame_cell{id{:}};
        else
            continue
        end
        if has_item(calculus, 'count_split_per_frame', id, false)
            count_split_per_frame = count_split_per_frame_cell{id{:}};
        else
            continue
        end
        if has_item(calculus, 'count_regions', id, false)
            count_regions = count_regions_cell{id{:}};
        else
            continue
        end
        if isfield(properties, 'visible') && properties.visible == 0
            fig = get_figure(properties.uuid_figure, number_fig, 'Visible', 'Off');
        else
            fig = get_figure(properties.uuid_figure, number_fig);
        end
        number_fig = number_fig + 1;
        clf(fig);
        ax = axes(fig);
        hold on
        bar(ax, ticks.time(time(1):time(2)), count_split_per_frame(time(1):time(2)), ...
            'r', 'DisplayName', 'Number of splits per frame', 'EdgeColor', 'none');
        bar(ax, ticks.time(time(1):time(2)), -count_merge_per_frame(time(1):time(2)), ...
            'g', 'DisplayName', 'Number of mergers per frame', 'EdgeColor', 'none');
        plot(ax, ticks.time(time(1):time(2)), count_regions(time(1):time(2)), ...
            'DisplayName', 'Number of regions per frame');
        hold off
        xlim(ax, [ticks.time(time(1)), ticks.time(time(2))]);
        xlabel(ax, [properties.x_label{1}, ' ', rescale_info.new_units{1}]);
        ylabel(ax, [properties.y_label{1}, ' ', rescale_info.new_units{2}]);
        if id{2} == 1
            postfix = ' ITMM';
        elseif id{2} == 2
            postfix = ' YuWei';
        end
        title(ax, [properties.title{1}, postfix]);
        legend(ax, '-DynamicLegend');
        xlim(ax, time);
        pretty_fig(fig);
    end
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Number of splits, number of mergers and number of regions per frame Painted.');
    end
end
