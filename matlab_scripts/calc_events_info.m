function [events_info] = calc_events_info (events_3d)
    n = numel(events_3d);
    starts = zeros(n, 1);
    finishes = zeros(n, 1);
    durations = zeros(n, 1);
    max_projections = zeros(n, 1);
    volumes = zeros(n, 1);
    
    for j=1:numel(events_3d)
        if iscell(events_3d) 
            x = events_3d{j}(:,1);
            y = events_3d{j}(:,2);
            t = events_3d{j}(:,3);
        elseif isstruct(events_3d)
            x = events_3d(j).PixelList(:,1);
            y = events_3d(j).PixelList(:,2);
            t = events_3d(j).PixelList(:,3);
        end
        starts(j) = min (t);
        finishes(j) = max (t);
        durations(j) = finishes(j) - starts(j) + 1;
        cnt = tabulate(single(t));
        max_projections(j) = max(cnt(:,2));
        volumes(j) = numel(t);
    end
    
    events_info.numbers = n;
    events_info.durations = durations;
    events_info.starts = starts;
    events_info.finishes = finishes;
    events_info.max_projections = max_projections;
    events_info.volumes = volumes;
    events_info.descriptions = { 'Number of events', 'Durations [sec]' , 'Event start [sec]' , 'Event end [sec]', ...
                                 'Maximal projection [pixels]', 'Volume [pixels]' };
end
