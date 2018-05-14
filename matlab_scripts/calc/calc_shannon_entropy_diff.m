function [calculus] = calc_shannon_entropy_diff(calculus, properties)
    add_info_log('Calculating shannon entropy diff per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    frame = calculus.frame;
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shannon_entropy_diff'))
        if ~iscell(calculus.shannon_entropy_diff)
            shannon_entropy_diff = cell(size(events_info_cell));
            shannon_entropy_diff{1, 1} = calculus.shannon_entropy_diff;
        else
            shannon_entropy_diff = calculus.shannon_entropy_diff;
        end
    else
        shannon_entropy_diff = cell(size(events_info_cell));
    end
    
    %% Calculate
    k = 0;
    for id = ids
        events_info = events_info_cell(id{:});
        if isempty(frame{id{:}}), continue;
        end
        points = frame{id{:}}.points;
        shannon_entropy_diff{id{:}} = zeros(events_info.nt, 1);
        for i = 1:events_info.nt
            if isempty(points{i}), continue, end
            frame_point = zeros(events_info.height, events_info.width);
            frame_point(sub2ind(size(frame_point), points{i}(:, 1), ...
                points{i}(:, 2))) = 1;
            f_x = diff(frame_point);
            f_y = diff(frame_point')';
            f_xy = (f_x(:, 1:events_info.width - 1) + 3) .* ...
                (f_y(1:events_info.height - 1, :) + 6);
            unique_value = unique(f_xy);
            for j = 1:length(unique_value)
                p = length(find(f_xy(:) == unique_value(j))) / ...
                    double(events_info.height * events_info.width);
                shannon_entropy_diff{id{:}}(i) = ...
                    shannon_entropy_diff{id{:}}(i) - xlogx(p);
            end
        end
        k = k + 1;
        add_info_log('Calculating shannon entropy diff per frame...', double(k) / length(ids));
    end
    
    %% Store data
    calculus.shannon_entropy_diff = shannon_entropy_diff;
    
    %%
    add_info_log('Shannon entropy diff per frame calculated.');
end
