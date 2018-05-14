function [calculus] = calc_configurations_res(calculus, properties)
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
    if ~isempty(whos(calculus, 'configurations_res'))
        if ~iscell(calculus.configurations_res)
            configurations_res = cell(size(events_info_cell));
            configurations_res{1, 1} = calculus.configurations_res;
            configurations_per_frame_res = cell(size(events_info_cell));
            configurations_per_frame_res{1, 1} = calculus.configurations_per_frame_res;
            configurations_merge_res = cell(size(events_info_cell));
            configurations_merge_res{1, 1} = calculus.configurations_merge_res;
        else
            configurations_res = calculus.configurations_res;
            configurations_per_frame_res = calculus.configurations_per_frame_res;
            configurations_merge_res = calculus.configurations_merge_res;
        end
    else
        configurations_res = cell(size(events_info_cell));
        configurations_per_frame_res = cell(size(events_info_cell));
        configurations_merge_res = cell(size(events_info_cell));
    end
    
    %% Calculate
    k = 0;
    add_info_log('Calculating configurations...', 0);
    for id = ids
        ENTROPY_WINDOW_SIZE = 3;
        if has_item(calculus, 'resized_video', id, false)
            resized_video = calculus.resized_video(id{:});
            resized_video = resized_video{1};
        else
            continue
        end
        frames_point = resized_video;
        size_video = size(resized_video);
        events_info = events_info_cell(id{:});
        height = size_video(1);
        width = size_video(2);
        shift = ENTROPY_WINDOW_SIZE - 1;
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
            frame_int_merge(:, :, i - 1) = ...
                int32(frame_int(:, :, i - 1)) + ...
                int32(frame_int(:, :, i)) * 2^(ENTROPY_WINDOW_SIZE^2);
        end
        
        configurations_res{id{:}} = Count(frame_int(:) + 1, ...
            2^(ENTROPY_WINDOW_SIZE^2), 'int32');
        
        configurations_per_frame_res{id{:}} = ...
            zeros(2^(ENTROPY_WINDOW_SIZE^2), events_info.nt, 'int32');
        for i = 1:events_info.nt
            ff = frame_int(:, :, i) + 1;
            configurations_per_frame_res{id{:}}(:, i) = ...
                Count(ff(:), 2^(ENTROPY_WINDOW_SIZE^2), 'int32');
        end
        configurations_merge_res{id{:}} = Count(frame_int_merge(:) + 1, ...
            2^(2 * ENTROPY_WINDOW_SIZE^2), 'int32');
        
        k = k + 1;
        add_info_log('Calculating configurations...', ...
            double(k) / length(ids));
    end
    
    %% Store data
    calculus.configurations_res = configurations_res;
    calculus.configurations_per_frame_res = configurations_per_frame_res;
    calculus.configurations_merge_res = configurations_merge_res;
    
    %%
    add_info_log('Configurations calculated.');
end
