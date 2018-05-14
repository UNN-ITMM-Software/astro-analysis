function calculus = calc_beginning_of_events(calculus, properties)
    add_info_log('Calculating histogram of beginning of events...');
    
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
        if ~isempty(whos(calculus, 'beginning_of_events'))
            if ~iscell(calculus.beginning_of_events)
                beginning_of_events = cell(size(events_info_cell));
                beginning_of_events{1} = calculus.beginning_of_events;
            else
                beginning_of_events = calculus.beginning_of_events;
            end
        else
            beginning_of_events = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            beginning_of_events{id{:}} = zeros(events_info.height, ...
                events_info.width, 'int32');
            area = events_3d.area;
            max_projections = events_info.max_projections;
            starts = events_info.starts;
            
            for i = 1:events_info.number
                % Remove events without a start
                if (area{i}(1, 2) < properties.max_points) || ...
                        (area{i}(1, 2) < max_projections(i) * properties.min_percent) && ...
                        ~(starts(i) > 1)
                    for j = 1:area{i}(1, 2)
                        x = events_3d.points{i}(j, 1);
                        y = events_3d.points{i}(j, 2);
                        beginning_of_events{id{:}}(x, y) = beginning_of_events{id{:}}(x, y) + 1;
                    end
                end
            end
        end
    end
    
    %% Store data
    calculus.beginning_of_events = beginning_of_events;
    
    %%
    add_info_log('Histogram of beginning of events calculated.');
end
