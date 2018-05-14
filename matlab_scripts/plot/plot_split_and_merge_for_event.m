function [fig] = plot_split_and_merge_for_event(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Painting number of splits, number of mergers and number of regions for event...');
    end
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Loading data
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    ids = get_ids(events_info_cell, id_algo, false);
    if ~isempty(whos(calculus, 'events_3d'))
        events_3d_cell = calculus.events_3d;
    else
        add_info_log('events_3d not found');
        return
    end
    if ~isempty(whos(calculus, 'count_merge'))
        count_merge_cell = calculus.count_merge;
    else
        add_info_log('count_merge not found');
        return
    end
    if ~isempty(whos(calculus, 'count_split'))
        count_split_cell = calculus.count_split;
    else
        add_info_log('count_split not found');
        return
    end
    if ~isempty(whos(calculus, 'count_regions_for_event'))
        count_regions_for_event_cell = calculus.count_regions_for_event;
    else
        add_info_log('count_regions_for_event not found');
        return
    end
    
    fig = [];
    number_fig = 0;
    for id = ids
        if ~isfield(properties, 'selected_events')
            selected_events = 0;
        else
            selected_events = properties.selected_events;
        end
        if has_item(calculus, 'events_3d', id, true)
            events_3d = events_3d_cell(id{:});
        else
            return
        end
        if has_item(calculus, 'events_info', id, true)
            events_info = events_info_cell(id{:});
        else
            return
        end
        if has_item(calculus, 'count_merge', id, false)
            count_merge = count_merge_cell{id{:}};
        else
            return
        end
        if has_item(calculus, 'count_regions_for_event', id, false)
            count_regions_for_event = count_regions_for_event_cell{id{:}};
        else
            return
        end
        if has_item(calculus, 'count_split', id, false)
            count_split = count_split_cell{id{:}};
        else
            return
        end
        if isfield(events_3d, 'centroids')
            centroids = events_3d.centroids;
        else
            return
        end
        if selected_events == 0
            selected_events = 1:events_info.number;
        end
        for i = 1:length(selected_events)
            if (length(centroids{selected_events(i), 1}) > 3 && ...
                    max(count_merge(selected_events(i), :)) > 0)
                %% Properties
                if isfield(properties, 'visible') && properties.visible == 0
                    fig = get_figure(properties.uuid_figure, 0, 'Visible', 'Off');
                else
                    fig = get_figure(properties.uuid_figure, 0);
                end
                number_fig = number_fig + 1;
                
                %% Painting
                clf(fig);
                ax = axes(fig);
                start_frame_event = events_3d.area{selected_events(i)}(1, 1);
                length_event = length(events_3d.area{selected_events(i)});
                finish_frame_event = events_3d.area{selected_events(i)} ...
                    (length_event, 1);
                mas_frame = start_frame_event:finish_frame_event;
                hold on
                bar(ax, mas_frame, count_split(selected_events(i), mas_frame), ...
                    'r', 'DisplayName', 'Number of splits for event', 'EdgeColor', 'none');
                bar(ax, mas_frame, -count_merge(selected_events(i), mas_frame), ...
                    'g', 'DisplayName', 'Number of mergers for event', 'EdgeColor', 'none');
                plot(ax, mas_frame, count_regions_for_event(selected_events(i), ...
                    mas_frame), 'DisplayName', 'Number of regions');
                hold off
                xlabel(ax, 'Time (frame)');
                ylabel(ax, 'Number');
                title(ax, ['Event ', int2str(selected_events(i))]);
                legend(ax, '-DynamicLegend');
                xlim(ax, [start_frame_event, finish_frame_event]);
                pretty_fig(fig);
            end
        end
    end
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Number of splits, number of mergers and number of regions for event painted.');
    end
end
