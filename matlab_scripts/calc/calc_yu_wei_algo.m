function calculus = calc_yu_wei_algo(calculus, properties, project)
    add_info_log('Yu Wei algo calculating...');
    
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
    
    %% Calculate
    params = struct();
    params.Nthr = 2.4;
    params.F0_smooth_primal_sec = 300;
    params.F0_smooth_sec = 100;
    params.Nthr_dFF = 2.4;
    warning('off', 'all')
    [Ca_dFF, Caf, Ca_Bif, Ca_F0, ...
        Events, Events_3d, time_yu_wei_find_events] = ...
        eval_gen_Ca2_Astro_2(params, input_video);
    warning('on', 'all')
    
    events_info.number = Events.EventsNumber;
    events_info.ids = int32(1:Events.EventsNumber).';
    events_info.starts = int32(Events.Events_start);
    events_info.finishes = int32(Events.Events_end);
    events_info.durations = int32(Events.EventDurations);
    events_info.max_projections = ...
        zeros(events_info.number, 1, 'int32');
    events_info.video_size = size(Ca_dFF);
    events_info.height = events_info.video_size(1);
    events_info.width = events_info.video_size(2);
    events_info.nt = events_info.video_size(3);
    events_info = calc_colors(events_info);
    ticks.width = 1:events_info.width;
    ticks.height = 1:events_info.height;
    ticks.time = 1:events_info.nt;
    real_size = project.astro_video_info.real_size;
    
    events_3d.ids = events_info.ids;
    for i = 1:Events.EventsNumber
        points = Events_3d(i).PixelList(:, [2, 1, 3]);
        events_3d.points{i, 1} = points;
        
        mask = zeros(events_info.height, events_info.width, 'logical');
        mask(points(:, 1) + events_info.height * (points(:, 2) - 1)) = 1;
        events_info.max_projections(i) = sum(mask(:) > 0);
    end
    
    %% Store data
    calculus.Ca_dFF = Ca_dFF;
    calculus.Caf = Caf;
    calculus.Ca_Bif = Ca_Bif;
    calculus.Ca_F0 = Ca_F0;
    calculus.events_info(id{:}) = events_info;
    calculus.events_3d(id{:}) = events_3d;
    calculus.time_yu_wei_find_events = time_yu_wei_find_events;
    calculus.ticks = ticks;
    calculus.real_size = real_size;
    
    %%
    add_info_log('Yu Wei algo calculated.');
end