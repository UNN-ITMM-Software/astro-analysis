function [calculus] = calc_calculus_statistic_per_frame(calculus, properties)
    add_info_log('Calculating calculus statistic...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Load data
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    for id = ids
        
        %% Calculate
        if ~isempty(whos(calculus, 'count_merge_per_frame'))
            count_merge_cell = calculus.count_merge_per_frame;
            calculus_statistic_per_frame(id{:}).count_merge.mean = ...
                mean(count_merge_cell{id{:}});
            calculus_statistic_per_frame(id{:}).count_merge.std = ...
                std(count_merge_cell{id{:}}(:));
        end
        if ~isempty(whos(calculus, 'count_split_per_frame'))
            count_split_cell = calculus.count_split_per_frame;
            calculus_statistic_per_frame(id{:}).count_split.mean = ...
                mean(count_split_cell{id{:}});
            calculus_statistic_per_frame(id{:}).count_split.std = ...
                std(count_split_cell{id{:}});
        end
        if ~isempty(whos(calculus, 'count_regions'))
            count_regions_cell = calculus.count_regions;
            calculus_statistic_per_frame(id{:}).count_regions.mean = ...
                mean(count_regions_cell{id{:}});
            calculus_statistic_per_frame(id{:}).count_regions.std = ...
                std(count_regions_cell{id{:}});
        end
        if ~isempty(whos(calculus, 'count_events'))
            count_events_cell = calculus.count_events;
            calculus_statistic_per_frame(id{:}).count_events.mean = ...
                mean(count_events_cell{id{:}});
            calculus_statistic_per_frame(id{:}).count_events.std = ...
                std(double(count_events_cell{id{:}}));
        end
        if ~isempty(whos(calculus, 'percent_luminescence_frame'))
            percent_luminescence_frame_cell = calculus.percent_luminescence_frame;
            calculus_statistic_per_frame(id{:}).percent_luminescence_frame.mean = ...
                mean(percent_luminescence_frame_cell{id{:}});
            calculus_statistic_per_frame(id{:}).percent_luminescence_frame.std = ...
                std(percent_luminescence_frame_cell{id{:}});
        end
        if ~isempty(whos(calculus, 'compactness_index_frame'))
            compactness_index_frame_cell = calculus.compactness_index_frame;
            calculus_statistic_per_frame(id{:}).compactness_index_frame.mean = ...
                mean(compactness_index_frame_cell{id{:}});
            calculus_statistic_per_frame(id{:}).compactness_index_frame.std = ...
                std(compactness_index_frame_cell{id{:}});
        end
    end
    
    %% Store data
    calculus.calculus_statistic_per_frame = calculus_statistic_per_frame;
    
    %%
    add_info_log('Calculus statistic calculated.');
end