function [calculus] = calc_correlation_all(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Calculating correlation...');
    end
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'correlations_all'))
        if ~iscell(calculus.correlations_all)
            correlations_all = cell(size(events_info_cell));
            correlations_all{1, 1} = calculus.correlations_all;
        else
            correlations_all = calculus.correlations_all;
        end
    else
        correlations_all = cell(size(events_info_cell));
    end
    
    %% Loading data
    ids = get_ids(properties, calculus, id_algo);
    arr_variable = {'percent_luminescence_frame', 'count_regions', 'count_merge_per_frame', 'count_split_per_frame', 'count_events', 'compactness_index_frame', ...
        'average_events_area', 'average_regions_area'};
    %% Painting
    for id = ids
        for i = 1:length(arr_variable)
            for j = 1:length(arr_variable)
                if ~isempty(whos(calculus, arr_variable{i}))
                    variable_1_cell = calculus.(arr_variable{i});
                    variable_1 = variable_1_cell{id{:}};
                end
                if ~isempty(whos(calculus, arr_variable{j}))
                    variable_2_cell = calculus.(arr_variable{j});
                    variable_2 = variable_2_cell{id{:}};
                end
                if ~isempty(variable_1) && ~isempty(variable_2)
                    [R, ~] = corrcoef(double(variable_1(:)), double(variable_2(:)), 'rows', 'complete');
                    correlations_all{id{:}}.([arr_variable{i}, '_vs_', arr_variable{j}]) = R(1, 2);
                end
            end
        end
    end
    
    %% Store data
    calculus.correlations_all = correlations_all;
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Correlation calculated.');
    end
end
