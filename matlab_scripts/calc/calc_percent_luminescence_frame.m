function [calculus] = calc_percent_luminescence_frame(calculus, properties)
    add_info_log('Calculating percent of active pixels per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        all_events_projection_area_cell = calculus.all_events_projection_area;
        count_points_cell = calculus.count_points;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'percent_luminescence_frame'))
            if ~iscell(calculus.percent_luminescence_frame)
                percent_luminescence_frame = cell(size(events_info_cell));
                percent_luminescence_frame{1} = calculus.percent_luminescence_frame;
            else
                percent_luminescence_frame = calculus.percent_luminescence_frame;
            end
        else
            percent_luminescence_frame = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            all_events_projection_area = all_events_projection_area_cell{id{:}};
            if isempty(all_events_projection_area)
                continue;
            end
            count_points = count_points_cell{id{:}};
            percent_luminescence_frame{id{:}} = zeros(events_info.nt, 1);
            for i = 1:events_info.nt
                percent_luminescence_frame{id{:}}(i) = double(count_points(i)) / ...
                    double(all_events_projection_area);
            end
        end
        
        %% Store data
        calculus.percent_luminescence_frame = percent_luminescence_frame;
        
    end
    
    %%
    add_info_log('Percent of active pixels per frame calculated.');
end
