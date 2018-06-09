function [calculus] = save_calculus_statistic_from_events(calculus, properties)
    add_info_log('Calculating calculus save...');
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isfield(properties, 'save_type')
        properties.save_type = 'mat';
    end
    events_info_cell = calculus.events_info;
    ids = get_ids(events_info_cell, id_algo, false);
    calculus_statistic_for_event_cell = calculus.calculus_statistic_for_event;
    %% Saved
    for id = ids
        name_algo = alg_name(id, false);
        properties.file_name = ['calculus_statistic_events_', name_algo];
        
        if isfield(properties, 'id_threshold') && ~isempty(properties.id_threshold)
            properties.file_name = ...
                [properties.file_name, '_thr_', num2str(properties.id_threshold)];
        end
        file_name = fullfile(properties.path, properties.file_name);
        if has_item(calculus, 'calculus_statistic_for_event', id, false)
            calculus_statistic_for_event = calculus_statistic_for_event_cell{id{:}};
        else
            continue;
        end
        if has_item(calculus, 'events_info', id, true)
            events_info = events_info_cell(id{:});
        else
            continue;
        end
        names = fieldnames(calculus_statistic_for_event);
        switch properties.save_type
            case 'csv'
                value{1} = [1:events_info.number]';
                VariableNames{1} = 'event';
                for i = 1:length(names)
                    value_struct = getfield(calculus_statistic_for_event, names{i});
                    value{2 * i} = value_struct.mean';
                    value{2 * i + 1} = value_struct.std';
                    VariableNames{2 * i} = [names{i}, '_mean'];
                    VariableNames{2 * i + 1} = [names{i}, '_std'];
                end
                T = table(value{:}, 'VariableNames', VariableNames);
                writetable(T, sprintf('%s.csv', file_name), ...
                    'delimiter', ';');
            case 'mat'
                value{1} = [1:events_info.number]';
                VariableNames{1} = 'event';
                for i = 1:length(names)
                    value_struct = getfield(calculus_statistic_for_event, names{i});
                    value{2 * i} = value_struct.mean';
                    value{2 * i + 1} = value_struct.std';
                    VariableNames{2 * i} = [names{i}, '_mean'];
                    VariableNames{2 * i + 1} = [names{i}, '_std'];
                end
                T = table(value{:}, 'VariableNames', VariableNames);
                save(sprintf('%s.mat', file_name), 'T');
                
            case {'png', 'eps'}
        end
        if ~isfield(properties, 'info_log') || properties.info_log
            add_info_log('Events saved.');
        end
    end
    add_info_log('Calculus statistic calculated.');
end