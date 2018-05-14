function [calculus] = calc_count_split(calculus, properties)
    add_info_log('Calculating count split of events regions per event...');
    
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
        if ~isempty(whos(calculus, 'count_split'))
            if ~iscell(calculus.count_split)
                count_split = cell(size(events_info_cell));
                count_split{1} = calculus.count_split;
            else
                count_split = calculus.count_split;
            end
        else
            count_split = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            centroids = events_3d.centroids;
            edges = events_3d.edges;
            count_split{id{:}} = zeros(events_info.number, events_info.nt, 'int32');
            for i = 1:events_info.number
                if length(centroids{i, 1}) > 5
                    for j = 1:length(edges{i})
                        if length(edges{i}{j}) > 1
                            count_split{id{:}}(i, centroids{i}(j, 3)) = ...
                                count_split{id{:}}(i, centroids{i}(j, 3)) + 1;
                        end
                    end
                end
            end
        end
        
        %% Store data
        calculus.count_split = count_split;
        
    end
    
    %%
    add_info_log('Count split of events regions per event calculated.');
end
