function calculus = calc_resized_video(calculus, properties)
    add_info_log('Calculating resized video ...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isfield(properties, 'coeff')
        coeff = 0.25;
    else
        coeff = properties.coeff;
    end
    calculus.resize_coef = coeff;
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if is_created(calculus, 'resized_video')
        if ~iscell(calculus.resized_video)
            resized_video = cell(size(events_info_cell));
        else
            resized_video = calculus.resized_video;
        end
    else
        resized_video = cell(size(events_info_cell));
    end
    
    %% Calculate
    frame = calculus.frame;
    k = 0;
    add_info_log('Calculating resized video...', 0);
    for id = ids
        events_info = events_info_cell(id{:});
        height = events_info.height;
        width = events_info.width;
        if isempty(frame{id{:}}), continue;
        end
        points = frame{id{:}}.points;
        frames_point = zeros(height, width, ...
            events_info.nt);
        for i = 1:events_info.nt
            if isempty(points{i}), continue, end
            frame_point = zeros(height, width);
            frame_point(sub2ind(size(frame_point), points{i}(:, 1), ...
                points{i}(:, 2))) = 1;
            frames_point(:, :, i) = frame_point;
        end
        resized_video{id{:}} = resize_video(frames_point, coeff);
        k = k + 1;
        add_info_log('Calculating resized video...', k / numel(ids));
    end
    
    %% Store data
    calculus.resized_video = resized_video;
    
    %%
    add_info_log('Configurations calculated.');
end