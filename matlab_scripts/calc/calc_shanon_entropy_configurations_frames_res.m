function [calculus] = calc_shanon_entropy_configurations_frames_res(calculus, properties)
    add_info_log('Calculating shannon entropy diff per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    ids = get_ids(properties, calculus, id_algo);
    if ~isempty(whos(calculus, 'configurations_per_frame_res'))
        configurations_per_frame_cell = calculus.configurations_per_frame_res;
    else
        add_info_log('configurations_per_frame_res not found');
        return
    end
    %ids = {{1,1},{2,1}};
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shanon_entropy_configurations_frames_res'))
        if ~iscell(calculus.shanon_entropy_configurations_frames_res)
            shanon_entropy_configurations_frames_res = cell(size(events_info_cell));
            shanon_entropy_configurations_frames_res{1} = calculus.shanon_entropy_configurations_frames_res;
        else
            shanon_entropy_configurations_frames_res = calculus.shanon_entropy_configurations_frames_res;
        end
    else
        shanon_entropy_configurations_frames_res = cell(size(events_info_cell));
    end
    
    %% Calculate
    k = 0;
    for id = ids
        events_info = events_info_cell(id{:});
        if has_item(calculus, 'configurations_per_frame', id, false)
            configurations_per_frame = configurations_per_frame_cell{id{:}};
        else
            continue;
        end
        shanon_entropy_configurations_frames_res{id{:}} = zeros(events_info.nt, 1);
        for i = 1:events_info.nt
            Sum_config = sum(configurations_per_frame(:, i));
            shanon_entropy_configurations_frames_res{id{:}}(i) = ...
                sum(-xlogx(double(configurations_per_frame(:, i)) / double(Sum_config)));
            
        end
        k = k + 1;
        add_info_log('Calculating shannon entropy diff per frame...', double(k) / length(ids));
    end
    
    %% Store data
    calculus.shanon_entropy_configurations_frames_res = shanon_entropy_configurations_frames_res;
    
    %%
    add_info_log('Shannon entropy diff per frame calculated.');
end
