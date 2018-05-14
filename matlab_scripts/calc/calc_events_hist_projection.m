function calculus = calc_events_hist_projection(calculus, properties)
    add_info_log('Calculating histogram of events projection...');
    
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
        events_3d_cell = calculus.events_3d;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'all_events_projection_area'))
            if ~iscell(calculus.all_events_projection_area)
                all_events_projection_area = cell(size(events_info_cell));
                events_hist_projection = cell(size(events_info_cell));
                all_events_projection_area{1} = calculus.all_events_projection_area;
                events_hist_projection{1} = calculus.events_hist_projection;
            else
                all_events_projection_area = calculus.all_events_projection_area;
                events_hist_projection = calculus.events_hist_projection;
            end
        else
            all_events_projection_area = cell(size(events_info_cell));
            events_hist_projection = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            if isempty(events_3d.points), continue;
            end
            events_hist_projection{id{:}} = zeros(events_info.height, ...
                events_info.width, 'int32');
            all_events_projection_area{id{:}} = 0;
            all_points = vertcat(events_3d.points{:});
            if isempty(all_points), continue, end
            tbl = tabulate(sub2ind(size(events_hist_projection{id{:}}), ...
                all_points(:, 1), all_points(:, 2)));
            ind = ind2sub(size(events_hist_projection{id{:}}), tbl(:, 1));
            events_hist_projection{id{:}}(ind) = int32(tbl(:, 2));
            all_events_projection_area{id{:}} = nnz(events_hist_projection{id{:}});
        end
        
        %% Store data
        calculus.events_hist_projection = events_hist_projection;
        
        calculus.all_events_projection_area = all_events_projection_area;
    end
    
    %%
    add_info_log('Histogram of events projection calculated.');
end
