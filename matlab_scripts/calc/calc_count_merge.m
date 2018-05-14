function [calculus] = calc_count_merge(calculus, properties)
    add_info_log('Calculating count merge of events regions per event...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Loading data
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        events_3d_cell = calculus.events_3d;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'count_merge'))
            if ~iscell(calculus.count_merge)
                count_merge = cell(size(events_info_cell));
                count_merge{1} = calculus.count_merge;
            else
                count_merge = calculus.count_merge;
            end
        else
            count_merge = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            centroids = events_3d.centroids;
            edges = events_3d.edges;
            count_merge{id{:}} = zeros(events_info.number, events_info.nt, 'int32');
            for i = 1:events_info.number
                if length(centroids{i, 1}) > 5
                    count_edge = zeros(length(centroids{i, 1}), 1);
                    for j = 1:length(edges{i})
                        for k = 1:length(edges{i}{j})
                            count_edge(edges{i}{j}(k)) = count_edge(edges{i}{j}(k)) + 1;
                        end
                    end
                    for j = 1:length(count_edge)
                        if count_edge(j) > 1
                            count_merge{id{:}}(i, centroids{i, 1}(j, 3) - 1) = ...
                                count_merge{id{:}}(i, centroids{i, 1}(j, 3) - 1) + 1;
                        end
                    end
                end
            end
        end
        
        %% Store data
        calculus.count_merge = count_merge;
        
    end
    
    %%
    add_info_log('Count merge of events regions per event calculated.');
end
