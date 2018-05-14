function calculus = calc_ending_of_events(calculus, properties)
    add_info_log('Calculating histogram of ending events...');
    
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
        if ~isempty(whos(calculus, 'end_of_events'))
            if ~iscell(calculus.end_of_events)
                end_of_events = cell(size(events_info_cell));
                end_of_events{1} = calculus.end_of_events;
            else
                end_of_events = calculus.end_of_events;
            end
        else
            end_of_events = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            end_of_events{id{:}} = zeros(events_info.height, events_info.width, 'int32');
            area = events_3d.area;
            points = events_3d.points;
            finishes = events_info.finishes;
            for i = 1:events_info.number
                if finishes(i) >= events_info.nt - 1
                    continue;
                end
                %Consider the beginning of the last frame
                cnt = length(area{i}(:, 2));
                final_frame = length(points{i}) - area{i}(cnt, 2);
                for j = final_frame:length(points{i})
                    x = points{i}(j, 1);
                    y = points{i}(j, 2);
                    end_of_events{id{:}}(x, y) = end_of_events{id{:}}(x, y) + 1;
                end
            end
        end
        
        %% Store data
        calculus.end_of_events = end_of_events;
        
    end
    
    %%
    add_info_log('Histogram of ending events calculated.');
end
