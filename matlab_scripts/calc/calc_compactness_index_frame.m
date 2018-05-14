function [calculus] = calc_compactness_index_frame(calculus, properties)
    add_info_log('Calculating compactness index per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        
        %% Load data
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        count_points_cell = calculus.count_points;
        frame_cell = calculus.frame;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'compactness_index_frame'))
            if ~iscell(calculus.compactness_index_frame)
                compactness_index_frame = cell(size(events_info_cell));
                compactness_index_frame{1} = calculus.compactness_index_frame;
            else
                compactness_index_frame = calculus.compactness_index_frame;
            end
        else
            compactness_index_frame = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            count_points = count_points_cell{id{:}};
            frame = frame_cell{id{:}};
            points = frame.points;
            center_of_mass_frame = zeros(events_info.nt, 2, 'double');
            dispersion = zeros(events_info.nt, 2, 'double');
            compactness_index_frame{id{:}} = zeros(events_info.nt, 1);
            for i = 1:events_info.nt
                for j = 1:count_points(i)
                    center_of_mass_frame(i, 1) = center_of_mass_frame(i, 1) + ...
                        double(points{i}(j, 1)) / double(count_points(i));
                    center_of_mass_frame(i, 2) = center_of_mass_frame(i, 2) + ...
                        double(points{i}(j, 2)) / double(count_points(i));
                end
                for j = 1:count_points(i)
                    dispersion(i, 1) = double(dispersion(i, 1)) + ...
                        double((center_of_mass_frame(i, 1) - points{i}(j, 1))^2);
                    dispersion(i, 2) = double(dispersion(i, 2)) + ...
                        double((center_of_mass_frame(i, 2) - points{i}(j, 2))^2);
                end
                compactness_index_frame{id{:}}(i) = double(count_points(i)^2) / ...
                    double(dispersion(i, 1) + dispersion(i, 2));
            end
        end
        
        %% Store data
        calculus.compactness_index_frame = compactness_index_frame;
        
    end
    
    %%
    add_info_log('Compactness index per frame calculated.');
end
