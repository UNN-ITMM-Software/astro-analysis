function [calculus] = calc_configurations(calculus, properties)
    add_info_log('Calculating configurations ...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'configurations'))
        if ~iscell(calculus.configurations)
            configurations = cell(size(events_info_cell));
            configurations{1, 1} = calculus.configurations;
            configurations_per_frame = cell(size(events_info_cell));
            configurations_per_frame{1, 1} = calculus.configurations_per_frame;
            configurations_merge = cell(size(events_info_cell));
            configurations_merge{1, 1} = calculus.configurations_merge;
        else
            configurations = calculus.configurations;
            configurations_per_frame = calculus.configurations_per_frame;
            configurations_merge = calculus.configurations_merge;
        end
    else
        configurations = cell(size(events_info_cell));
        configurations_per_frame = cell(size(events_info_cell));
        configurations_merge = cell(size(events_info_cell));
    end
    
    %% Calculate
    frame = calculus.frame;
    k = 0;
    add_info_log('Calculating configurations...', 0);
    for id = ids
        if (id{1} == 1), continue;
        end;
        ENTROPY_WINDOW_SIZE = 3;
        events_info = events_info_cell(id{:});
        height = events_info.height;
        width = events_info.width;
        shift = ENTROPY_WINDOW_SIZE - 1;
        if isempty(frame{id{:}}), continue;
        end
        points = frame{id{:}}.points;
        frames_point = zeros(height, width, ...
            events_info.nt, 'int8');
        for i = 1:events_info.nt
            if isempty(points{i}), continue, end
            frame_point = zeros(height, width, 'int8');
            frame_point(sub2ind(size(frame_point), points{i}(:, 1), ...
                points{i}(:, 2))) = 1;
            frames_point(:, :, i) = frame_point;
        end
        B = int16(reshape(2.^((1:(ENTROPY_WINDOW_SIZE^2)) - 1), ...
            ENTROPY_WINDOW_SIZE, ENTROPY_WINDOW_SIZE));
        frame_int = zeros(height - shift, width - shift, ...
            events_info.nt, 'int32');
        
        for i = 1:size(frames_point, 3)
            frame_int(:, :, i) = filter2(B, frames_point(:, :, i), 'valid');
        end
        frame_int_merge = zeros(height - shift, width - shift, ...
            events_info.nt - 1, 'int32');
        for i = 2:events_info.nt
            frame_int_merge(:, :, i - 1) = int32(frame_int(:, :, i - 1)) * 512 ...
                +int32(frame_int(:, :, i));
        end
        configurations{id{:}} = Count(frame_int(:) + 1, 2^(ENTROPY_WINDOW_SIZE^2), ...
            'int32');
        
        configurations_per_frame{id{:}} = ...
            zeros(2^(ENTROPY_WINDOW_SIZE^2), ...
            events_info.nt, 'int32');
        for i = 1:events_info.nt
            ff = frame_int(:, :, i) + 1;
            configurations_per_frame{id{:}}(:, i) = ...
                Count(ff(:), 2^(ENTROPY_WINDOW_SIZE^2), 'int32');
        end
        configurations_merge{id{:}} = Count(frame_int_merge(:) + 1, ...
            2^(2 * ENTROPY_WINDOW_SIZE^2), 'int32');
        
        k = k + 1;
        add_info_log('Calculating configurations...', ...
            double(k) / length(ids));
    end
    
    %% Store data
    calculus.configurations = configurations;
    calculus.configurations_per_frame = configurations_per_frame;
    calculus.configurations_merge = configurations_merge;
    
    %%
    add_info_log('Configurations calculated.');
end
