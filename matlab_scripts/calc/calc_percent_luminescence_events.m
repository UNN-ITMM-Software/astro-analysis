function calculus = calc_percent_luminescence_events(calculus, properties)
    add_info_log('Calculating percent of active events pixels...');
    
    %% Properties
    id_algo = properties.id_algorithm;
    
    %% Load data
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        events_3d_cell = calculus.events_3d;
        
        if ~isempty(whos(calculus, 'percent_luminescence_events'))
            if ~iscell(calculus.percent_luminescence_events)
                percent_luminescence_events = cell(size(events_info_cell));
                percent_luminescence_events{1} = calculus.percent_luminescence_events;
            else
                percent_luminescence_events = calculus.percent_luminescence_events;
            end
        else
            percent_luminescence_events = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            area = events_3d.area;
            max_projections = events_info.max_projections;
            percent_luminescence_events{id{:}} = struct('percent_luminescence', []);
            for i = 1:events_info.number
                percent_luminescence_events{id{:}}.percent_luminescence{i, 1} = ...
                    zeros(length(area{i, 1}), 2, 'double');
                percent_luminescence_events{id{:}}.percent_luminescence{i, 1}(:, 1) = ...
                    area{i, 1}(:, 1);
                percent_luminescence_events{id{:}}.percent_luminescence{i, 1}(:, 2) = ...
                    area{i, 1}(:, 2) / double(max_projections(i, 1));
            end
        end
        
        %% Store data
        calculus.percent_luminescence_events = percent_luminescence_events;
        
    end
    
    %%
    add_info_log('Percent of active events pixels calculated.');
end
