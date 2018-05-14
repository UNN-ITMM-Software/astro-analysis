function [] = save_count_merge_split_regions_for_event(calculus, properties)
    add_info_log('Saving plot count/merge/split regions for event...');
    
    %% Cache data
    cache(calculus, 'events_info');
    cache(calculus, 'count_split');
    cache(calculus, 'count_merge');
    cache(calculus, 'events_3d');
    cache(calculus, 'count_regions_for_event');
    
    %% Cache data
    cache(calculus, 'events_info');
    cache(calculus, 'percent_luminescence_events');
    
    %% Load data
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Load data
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    ids = get_ids(events_info_cell, id_algo, false);
    
    for id = ids
        
        %% Properties
        if ~isfield(properties, 'selected_events')
            properties.selected_events = [];
        else
            properties.selected_events = 1:events_info_cell(id{:}).number;
        end
        if ~isfield(properties, 'file_name') || ...
                strcmp(properties.file_name, '')
            file_name_pref = 'count_merge_split_regions';
        else
            file_name_pref = properties.file_name;
        end
        if ~isfield(properties, 'save_type')
            properties.save_type = 'png';
        end
        
        %% Save
        properties.visible = false;
        properties.info_log = false;
        for i = 1:length(properties.selected_events)
            name_algo = alg_name(id, false);
            add_info_log('Saving plot count/merge/split regions for event...', ...
                double(i) / double(length(properties.selected_events)));
            file_name = [file_name_pref, '_', ...
                int2str(properties.selected_events(i)), ...
                '_', 'event_', name_algo];
            file_name = fullfile(properties.path, file_name);
            switch properties.save_type
                case {'png', 'eps'}
                    properties_cur = properties;
                    properties_cur.selected_events = ...
                        properties.selected_events(i);
                    fig = plot_split_and_merge_for_event(calculus, ...
                        properties_cur);
                    if ~isempty(fig)
                        save_fig(fig, file_name, [0, 0, 10, 7], ...
                            properties.save_type, false);
                        close(fig);
                    end
            end
        end
    end
    
    %% Uncache data
    uncache(calculus, 'events_info');
    uncache(calculus, 'count_split');
    uncache(calculus, 'count_merge');
    uncache(calculus, 'events_3d');
    uncache(calculus, 'centroids');
    uncache(calculus, 'count_regions_for_event');
    
    %%
    add_info_log('Plot count/merge/split regions for event saved.');
end
