function [calculus] = calc_shannon_entropy_res(calculus, properties)
    add_info_log('Calculating shannon entropy per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shannon_entropy_res'))
        if ~iscell(calculus.shannon_entropy_res)
            shannon_entropy_res = cell(size(events_info_cell));
            shannon_entropy_res{1, 1} = calculus.shannon_entropy_res;
        else
            shannon_entropy_res = calculus.shannon_entropy_res;
        end
    else
        shannon_entropy_res = cell(size(events_info_cell));
    end
    
    %% Calculate
    for id = ids
        events_info = events_info_cell(id{:});
        if has_item(calculus, 'resized_video', id, false)
            resized_video = calculus.resized_video(id{:});
            resized_video = resized_video{1};
        else
            continue
        end
        size_video = size(resized_video);
        shannon_entropy_res{id{:}} = zeros(events_info.nt, 1);
        for i = 1:events_info.nt
            resized_frame = resized_video(:, :, i);
            p = double(sum(resized_frame(:))) / ...
                double(size_video(1) * size_video(2));
            shannon_entropy_res{id{:}}(i) = -xlogx(p) - xlogx(1 - p);
        end
    end
    
    %% Store data
    calculus.shannon_entropy_res = shannon_entropy_res;
    
    %%
    add_info_log('Shannon entropy res per frame calculated.');
end
