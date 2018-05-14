function [calculus] = calc_frame_points(calculus, properties)
    add_info_log('Calculating active points per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'frame'))
        if ~iscell(calculus.frame)
            frame = cell(size(events_info_cell));
            count_points = cell(size(events_info_cell));
            frame{1} = calculus.frame;
            count_points{1} = calculus.count_points;
        else
            frame = calculus.frame;
            count_points = calculus.count_points;
        end
    else
        frame = cell(size(events_info_cell));
        count_points = cell(size(events_info_cell));
    end
    
    %% Calculate
    for id = ids
        events_info = events_info_cell(id{:});
        events_3d = calculus.events_3d(id{:});
        points = events_3d.points;
        frame{id{:}} = struct('points', []);
        count_points{id{:}} = zeros(events_info.nt, 1, 'int32');
        
        arr = cell(events_info.nt, 1);
        for i = 1:events_info.number
            c = [0; find(diff(points{i}(:, 3))); length(points{i})];
            for j = 1:(length(c) - 1)
                from = c(j) + 1;
                to = c(j + 1);
                curt = points{i}(c(j) + 1, 3);
                cur = int16([points{i}(from:to, 1:2), repmat(i, to - from + 1, 1)]);
                arr{curt} = [arr{curt}; cur];
            end
        end
        frame{id{:}}.points = arr;
        for i = 1:events_info.nt
            count_points{id{:}}(i) = size(arr{i}, 1);
        end
    end
    
    %% Store data
    calculus.frame = frame;
    calculus.count_points = count_points;
    
    %%
    add_info_log('Active points per frame calculated');
end
