function calculus = calc_events(calculus, properties, project)
    add_info_log('Calculating events.');
    
    %% Load config
    persistent config
    new_config = parse_config();
    if ~isequal(config, new_config)
        config = new_config;
        disp_conf_parameters(config);
    end
    
    a = int32(str2double(config.WINDOWSIDE));
    min_points = int32(str2double(config.MINPOINTS));
    eps = int32(str2double(config.EPS));
    thr_area = str2double(config.THRESHOLDAREA);
    thr_time = str2double(config.THRESHOLDTIME);
    min_area = int32(str2double(config.MINAREA));
    min_duration = int32(str2double(config.MINDURATION));
    
    %% Load data
    input_video = calculus.(properties.input_video);
    id = properties.id_events;
    if ~is_created(calculus, 'events_info') || isempty(calculus.events_info)
        [events_info, events_3d] = make_events_structs();
        calculus.events_info = events_info;
        calculus.events_3d = events_3d;
    elseif has_item(calculus, 'events_info', id, false)
        events_info = calculus.events_info(id{:});
        events_3d = calculus.events_3d(id{:});
    else
        [events_info, events_3d] = make_events_structs();
    end
    
    add_info_log('Finding events...');
    
    %% Calculate
    tic
    [events_3d_, events_info_] = find_events(input_video, ...
        struct('a', a, ...
        'min_points', min_points, ...
        'eps', eps, ...
        'thr_area', thr_area, ...
        'thr_time', thr_time, ...
        'min_area', min_area, ...
        'min_duration', min_duration));
    time_itmm_find_events = toc;
    add_info_log('Updating events info...');
    
    events_info = upd_struct(events_info_, events_info);
    events_3d = upd_struct(events_3d_, events_3d);
    
    events_info.video_size = size(input_video);
    events_info.height = events_info.video_size(1);
    events_info.width = events_info.video_size(2);
    events_info.nt = events_info.video_size(3);
    ticks.width = 1:events_info.width;
    ticks.height = 1:events_info.height;
    ticks.time = 1:events_info.nt;
    real_size = project.astro_video_info.real_size;
    if isfield(events_info, 'numbers')
        events_info.number = events_info.numbers;
        events_info = rmfield(events_info, 'numbers');
    end
    
    %% Store calculus
    add_info_log('Store events...');
    calculus.events_info(id{:}) = events_info;
    clear events_info;
    calculus.events_3d(id{:}) = events_3d;
    clear events_3d;
    calculus.time_itmm_find_events = time_itmm_find_events;
    calculus.ticks = ticks;
    calculus.real_size = real_size;
    
    %% Calculate extension info
    calculus = calc_ext_info(calculus, properties);
    
    %%
    add_info_log('Events calculated.');
end
