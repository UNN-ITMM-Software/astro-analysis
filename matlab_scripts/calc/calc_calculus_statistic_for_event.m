function [calculus] = calc_calculus_statistic_for_event(calculus, properties)
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
    events_3d_cell = calculus.events_3d;
    if is_created(calculus, 'calculus_statistic_for_event')
        if ~iscell(calculus.calculus_statistic_for_event)
            calculus_statistic_for_event = cell(size(events_info_cell));
            calculus_statistic_for_event{1} = calculus.calculus_statistic_for_event;
        else
            calculus_statistic_for_event = calculus.calculus_statistic_for_event;
        end
    else
        calculus_statistic_for_event = cell(size(events_info_cell));
    end
    k = 0;
    if ~isempty(whos(calculus, 'count_merge'))
        count_merge_cell = calculus.count_merge;
    end
    if ~isempty(whos(calculus, 'count_split'))
        count_split_cell = calculus.count_split;
    end
    if ~isempty(whos(calculus, 'count_regions_for_event')) && ...
            ~isempty(calculus.count_regions_for_event)
        count_regions_cell = calculus.count_regions_for_event;
    end
    if ~isempty(whos(calculus, 'percent_luminescence_events'))
        percent_luminescence_events_cell = calculus.percent_luminescence_events;
    end
    for id = ids
        events_3d = events_3d_cell(id{:});
        events_info = events_info_cell(id{:});
        centroids = events_3d.centroids;
        number_event = 0;
        
        %% Calculate
        for i = 1:events_info.number
            number_event = number_event + 1;
            start_frame_event = events_3d.area{i}(1, 1);
            length_event = length(events_3d.area{i});
            finish_frame_event = events_3d.area{i}(length_event, 1);
            mas_frame = start_frame_event:finish_frame_event;
            if ~isempty(whos(calculus, 'count_merge'))
                calculus_statistic_for_event{id{:}}.count_merge.mean(number_event) = ...
                    mean(count_merge_cell{id{:}}(i, mas_frame));
                calculus_statistic_for_event{id{:}}.count_merge.std(number_event) = ...
                    std(double(count_merge_cell{id{:}}(i, mas_frame)));
            end
            if ~isempty(whos(calculus, 'count_split'))
                calculus_statistic_for_event{id{:}}.count_split.mean(number_event) = ...
                    mean(count_split_cell{id{:}}(i, mas_frame));
                calculus_statistic_for_event{id{:}}.count_split.std(number_event) = ...
                    std(double(count_split_cell{id{:}}(i, mas_frame)));
            end
            if ~isempty(whos(calculus, 'count_regions_for_event')) && ...
                    ~isempty(calculus.count_regions_for_event)
                cur_count_regions_cell = count_regions_cell{id{:}};
                if ~isempty(cur_count_regions_cell)
                    calculus_statistic_for_event{id{:}}.count_regions.mean(number_event) = ...
                        mean(cur_count_regions_cell(i, mas_frame));
                    calculus_statistic_for_event{id{:}}.count_regions.std(number_event) = ...
                        std(double(cur_count_regions_cell(i, mas_frame)));
                end
            end
            
            if ~isempty(whos(calculus, 'percent_luminescence_events'))
                percent_luminescence = percent_luminescence_events_cell{id{:}}.percent_luminescence;
                mas_frame = percent_luminescence{i}(:, 1);
                calculus_statistic_for_event{id{:}}.percent_luminescence_events.mean(number_event) = ...
                    mean(percent_luminescence{i}(:, 2));
                calculus_statistic_for_event{id{:}}.percent_luminescence_events.std(number_event) = ...
                    std(percent_luminescence{i}(:, 2));
            end
        end
        k = k + 1;
        add_info_log('Calculus statistic calculating...', k / numel(ids));
    end
    
    %% Store data
    calculus.calculus_statistic_for_event = calculus_statistic_for_event;
    
    %%
    add_info_log('Calculus statistic calculated.');
end
