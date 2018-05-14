function [calculus] = calc_average_regions_area(calculus, properties)
    add_info_log('Calculating average regions area...');
    
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
        count_regions_cell = calculus.count_regions;
        count_points_cell = calculus.count_points;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'average_regions_area'))
            if ~iscell(calculus.average_regions_area)
                average_regions_area = cell(size(events_info_cell));
                average_regions_area{1} = calculus.average_regions_area;
            else
                average_regions_area = calculus.average_regions_area;
            end
        else
            average_regions_area = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            if has_item(calculus, 'events_info', id, true)
                events_info = events_info_cell(id{:});
            else
                continue
            end
            if has_item(calculus, 'count_regions', id, false)
                count_regions = count_regions_cell{id{:}};
            else
                continue
            end
            if has_item(calculus, 'count_points', id, false)
                count_points = count_points_cell{id{:}};
            else
                continue
            end
            average_regions_area{id{:}} = zeros(events_info.nt, 1);
            for i = 1:events_info.nt
                if count_points(i) == 0 || count_regions(i) == 0
                    average_regions_area{id{:}}(i) = 0;
                else
                    average_regions_area{id{:}}(i) = double(count_points(i)) / ...
                        double(count_regions(i));
                end
            end
        end
        
        %% Store data
        calculus.average_regions_area = average_regions_area;
        
    end
    
    %%
    add_info_log('Average regions area calculated.');
end
