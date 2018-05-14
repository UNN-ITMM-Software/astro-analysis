function [calculus] = calc_average_events_area(calculus, properties)
    add_info_log('Calculating average events area...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Load data
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        count_events_cell = calculus.count_events;
        count_points_cell = calculus.count_points;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'average_events_area'))
            if ~iscell(calculus.average_events_area)
                average_events_area = cell(size(events_info_cell));
                average_events_area{1} = calculus.average_events_area;
            else
                average_events_area = calculus.average_events_area;
            end
        else
            average_events_area = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            if has_item(calculus, 'events_info', id, true)
                events_info = events_info_cell(id{:});
            else
                continue
            end
            if has_item(calculus, 'count_events', id, false)
                count_events = count_events_cell{id{:}};
            else
                continue
            end
            if has_item(calculus, 'count_points', id, false)
                count_points = count_points_cell{id{:}};
            else
                continue
            end
            average_events_area{id{:}} = zeros(events_info.nt, 1);
            for i = 1:events_info.nt
                if count_points(i) == 0 || count_events(i) == 0
                    average_events_area{id{:}}(i) = 0;
                else
                    average_events_area{id{:}}(i) = double(count_points(i)) / ...
                        double(count_events(i));
                end
            end
        end
        
        %% Store data
        calculus.average_events_area = average_events_area;
        
    end
    
    %%
    add_info_log('Average events area calculated.');
end
