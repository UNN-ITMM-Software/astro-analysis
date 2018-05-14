function [calculus] = calc_shannon_entropy_diff_res(calculus, properties)
    add_info_log('Calculating shannon entropy diff res per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shannon_entropy_diff_res'))
        if ~iscell(calculus.shannon_entropy_diff_res)
            shannon_entropy_diff_res = cell(size(events_info_cell));
            shannon_entropy_diff_res{1, 1} = calculus.shannon_entropy_diff_res;
        else
            shannon_entropy_diff_res = calculus.shannon_entropy_diff_res;
        end
    else
        shannon_entropy_diff_res = cell(size(events_info_cell));
    end
    
    %% Calculate
    k = 0;
    for id = ids
        events_info = events_info_cell(id{:});
        if has_item(calculus, 'resized_video', id, false)
            resized_video = calculus.resized_video(id{:});
            resized_video = resized_video{1};
        else
            continue
        end
        shannon_entropy_diff_res{id{:}} = zeros(events_info.nt, 1);
        size_video = size(resized_video);
        for i = 1:events_info.nt
            frame_point = resized_video(:, :, i);
            f_x = diff(frame_point);
            f_y = diff(frame_point')';
            f_xy = (f_x(:, 1:size_video(1) - 1) + 3) .* ...
                (f_y(1:size_video(2) - 1, :) + 6);
            unique_value = unique(f_xy);
            for j = 1:length(unique_value)
                p = length(find(f_xy(:) == unique_value(j))) / ...
                    double(size_video(1) * size_video(2));
                shannon_entropy_diff_res{id{:}}(i) = ...
                    shannon_entropy_diff_res{id{:}}(i) - xlogx(p);
            end
        end
        k = k + 1;
        add_info_log('Calculating shannon entropy diff res per frame...', double(k) / length(ids));
    end
    
    %% Store data
    calculus.shannon_entropy_diff_res = shannon_entropy_diff_res;
    
    %%
    add_info_log('Shannon entropy diff res per frame calculated.');
end
