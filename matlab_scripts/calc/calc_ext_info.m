% Update to matlab style; add colors;
function [calculus] = calc_ext_info(calculus, properties)
    add_info_log('Calculating extension info for events...');
    
    %% Load data
    id = properties.id_events;
    events_info = calculus.events_info(id{:});
    events_3d = calculus.events_3d(id{:});
    
    %% Calculate
    for s = 1:events_info.number
        events_3d.points{s} = events_3d.points{s}(:, [2, 1, 3]) + 1;
    end
    events_info = calc_colors(events_info);
    
    %% Store data
    calculus.events_3d(id{:}) = events_3d;
    calculus.events_info(id{:}) = events_info;
end
