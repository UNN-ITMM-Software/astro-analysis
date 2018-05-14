function [] = save_for_event(calculus, properties)
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Saving ', properties.full_name, '...']);
    end
    
    %% Cache data
    cache(calculus, 'events_info');
    if ~isempty(whos(calculus, properties.variable))
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    cache(calculus, 'events_3d');
    
    %% Load data
    id_algo = properties.id_algorithm;
    
    %% Load data
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    ids = get_ids(properties, calculus, id_algo);
    if ~isempty(whos(calculus, 'events_3d'))
        events_3d_cell = calculus.events_3d;
    else
        add_info_log('events_3d not found');
        return
    end
    rescale_info = rescale_variable(calculus, properties);
    for id = ids
        percent_luminescence = 0;
        if has_item(calculus, 'events_3d', id, true)
            events_3d = events_3d_cell(id{:});
        else
            continue;
        end
        if has_item(calculus, 'events_info', id, true)
            events_info = events_info_cell(id{:});
        else
            continue;
        end
        if has_item(calculus, properties.variable, id, false)
            variable = variables{id{:}};
            if isstruct(variable)
                variable = variable.percent_luminescence;
                percent_luminescence = 1;
            end
        else
            continue
        end
        if isfield(events_3d, 'area')
            area = events_3d.area;
        else
            continue;
        end
        
        %% Properties
        if ~isfield(properties, 'selected_events')
            properties.selected_events = [];
        end
        if properties.selected_events == 0
            properties.selected_events = 1:events_info.number;
        end
        file_name_pref = properties.file_name;
        if ~isfield(properties, 'save_type')
            properties.save_type = 'mat';
        end
        
        %% Save
        for i = 1:length(properties.selected_events)
            name_algo = alg_name(id, false);
            file_name = [file_name_pref, '_', ...
                int2str(properties.selected_events(i)), ...
                '_', 'event_', name_algo];
            file_name = fullfile(properties.path, file_name);
            start_frame_event = ...
                area{properties.selected_events(i)}(1, 1);
            length_event = length(area{properties.selected_events(i)});
            finish_frame_event = area{properties.selected_events(i)} ...
                (length_event, 1);
            if percent_luminescence == 0
                time = [start_frame_event:finish_frame_event]';
                value = [variable(properties.selected_events(i), time)]';
                
            else
                mas_frame = variable{properties.selected_events(i)}(:, 1);
                value = variable{properties.selected_events(i)}(:, 2);
                time = mas_frame;
            end
            switch properties.save_type
                case 'csv'
                    
                    T = table(rescale_info.new_coef(1) * time, value);
                    writetable(T, sprintf('%s.csv', file_name), ...
                        'delimiter', ';');
                case 'mat'
                    start_frame_event = ...
                        area{properties.selected_events(i)}(1, 1);
                    length_event = length(area{properties.selected_events(i)});
                    finish_frame_event = area{properties.selected_events(i)} ...
                        (length_event, 1);
                    if ff == 0
                        value = [variable(properties.selected_events(i), time)]';
                        time = [start_frame_event:finish_frame_event]';
                    else
                        mas_frame = variable{selected_events(i)}(:, 1);
                        value = variable{properties.selected_events(i)}(:, 2);
                        time = mas_frame;
                    end
                    variable = table(rescale_info.new_coef(1) * time, value);
                    save(sprintf('%s.mat', file_name), 'variable');
                case {'png', 'eps'}
                    properties_cur = properties;
                    properties_cur.selected_events = properties.selected_events(i);
                    properties_cur.id_algorithm = id{2};
                    fig = plot_for_event(calculus, ...
                        setfield(properties_cur, 'visible', 0));
                    if ~isempty(fig)
                        save_fig(fig, file_name, [0, 0, 16, 9], properties.save_type, false);
                        close(fig);
                    end
            end
        end
    end
    
    %% Uncache data
    uncache(calculus, 'events_info');
    uncache(calculus, 'events_3d');
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' painteed.']);
    end
end
