function calculus = calc_count_events(calculus, properties)
    add_info_log('Calculating count events per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Load data
    if ~isempty(whos(calculus, 'events_info')) && ...
            ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        events_3d_cell = calculus.events_3d;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'count_events'))
            if ~iscell(calculus.count_events)
                count_events = cell(size(events_info_cell));
                count_events{1} = calculus.count_events;
            else
                count_events = calculus.count_events;
            end
        else
            count_events = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            count_events{id{:}} = zeros(events_info.nt, 1, 'int32');
            spoint = events_3d.spoints;
            for i = 1:events_info.number
                cnt = length(spoint{i}(:, 3));
                if cnt > 0
                    frames = spoint{i}(1, 3):spoint{i}(cnt, 3);
                    count_events{id{:}}(frames) = count_events{id{:}}(frames) + 1;
                end
            end
        end
        
        %% Store data
        calculus.count_events = count_events;
        
    end
    
    %%
    add_info_log('Count events per frame calculated.');
end
