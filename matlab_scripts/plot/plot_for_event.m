function [fig] = plot_for_event(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Painting ', properties.full_name, '...']);
    end
    id_algo = properties.id_algorithm;
    ids = get_ids(properties, calculus, id_algo);
    if ~isempty(whos(calculus, 'events_3d'))
        events_3d_cell = calculus.events_3d;
    else
        add_info_log('events_3d not found');
        return
    end
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    if ~isempty(whos(calculus, properties.variable))
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    rescale_info = rescale_variable(calculus, properties);
    ticks = calculus.ticks;
    ticks.time = ticks.time * rescale_info.new_coef(1);
    fig = [];
    
    %% Basic cycle
    for id = ids
        ff = 0;
        if ~isfield(properties, 'selected_events')
            selected_events = 0;
        else
            selected_events = properties.selected_events;
        end
        if has_item(calculus, 'events_3d', id, true)
            events_3d = events_3d_cell(id{:});
        else
            continue
        end
        if has_item(calculus, 'events_info', id, true)
            events_info = events_info_cell(id{:});
        else
            continue
        end
        if has_item(calculus, properties.variable, id, false)
            variable = variables{id{:}};
            if isstruct(variable)
                variable = variable.percent_luminescence;
                ff = 1;
            end
        else
            continue
        end
        if isfield(events_3d, 'centroids')
            centroids = events_3d.centroids;
        else
            return
        end
        if selected_events == 0
            selected_events = 1:events_info.number;;
            flag = 1;
        end
        for i = 1:length(selected_events)
            if (length(centroids{selected_events(i), 1}()) > 3)
                
                %% Properties
                if isfield(properties, 'visible') && properties.visible == 0
                    fig = get_figure(properties.uuid_figure, selected_events(i), 'Visible', 'Off');
                else
                    fig = get_figure(properties.uuid_figure, selected_events(i));
                end
                
                %% Painting
                if id{2} == 1
                    cname = '(ITMM)';
                    name = [properties.title{1}, ' ', int2str(selected_events(i)), ' (ITMM)'];
                    color = [1, 0, 0];
                else if id{2} == 2
                        cname = '(Yu Wei)';
                        name = [properties.title{1}, ' ', int2str(selected_events(i)), ' (Yu Wei)'];
                        color = [1, 0.7, 0];
                    end
                end
                clf(fig);
                ax = axes(fig);
                start_frame_event = events_3d.area{selected_events(i)}(1, 1);
                length_event = length(events_3d.area{selected_events(i)});
                finish_frame_event = events_3d.area{selected_events(i)} ...
                    (length_event, 1);
                mas_frame = start_frame_event:finish_frame_event;
                if ff == 0
                    plot(ax, ticks.time(mas_frame), variable(selected_events(i), ...
                        mas_frame), 'DisplayName', cname, 'LineWidth', 5, 'Color', color);
                else
                    mas_frame = variable{selected_events(i)}(:, 1);
                    plot(ax, ticks.time(mas_frame), variable{selected_events(i)}(:, 2), ...
                        'DisplayName', cname, 'LineWidth', 5, 'Color', color);
                end
                xlabel(ax, [properties.x_label{1}, ' ', rescale_info.new_units{1}]);
                ylabel(ax, [properties.y_label{1}, ' ', rescale_info.new_units{2}]);
                title(ax, name);
                legend(ax, '-DynamicLegend');
                xlim(ax, [min(ticks.time(mas_frame)), ...
                    max(ticks.time(mas_frame))]);
                pretty_fig(fig);
            end
        end
    end
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' painteed.']);
    end
end
