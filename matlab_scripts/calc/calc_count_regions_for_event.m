function [calculus] = calc_count_regions_for_event(calculus, properties)
    add_info_log('Calculating count regions for event...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Loading data
    if ~isempty(whos(calculus, 'events_info')) && ...
            ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        events_3d_cell = calculus.events_3d;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'count_regions_for_event'))
            if ~iscell(calculus.count_regions_for_event)
                count_regions = cell(size(events_info_cell));
                count_regions{1} = calculus.count_regions_for_event;
            else
                count_regions = calculus.count_regions_for_event;
            end
        else
            count_regions = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            count_regions{id{:}} = zeros(events_info.number, events_info.nt);
            for i = 1:events_info.number
                for j = 2:length(events_3d.components_ptr{i})
                    frame = events_3d.border{i}(events_3d.components_ptr{i}(j) - 1, 3);
                    count_regions{id{:}}(i, frame) = count_regions{id{:}}(i, frame) + 1;
                end
            end
        end
        
        %% Store data
        calculus.count_regions_for_event = count_regions;
        
    end
    
    %%
    add_info_log('Count regions per frame calculated.');
end
