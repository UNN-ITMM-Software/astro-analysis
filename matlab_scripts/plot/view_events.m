function [out] = view_events(calculus, properties)
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isfield(properties, 'id_threshold')
        id_threshold = 1;
    else
        id_threshold = properties.id_threshold + 1;
    end
    
    events_3d = calculus.events_3d(id_threshold, id_algo);
    events_info = calculus.events_info(id_threshold, id_algo);
    
    if ~isfield(properties, 'selected_events') || ...
            properties.selected_events == 0
        ids = 1:events_info.number;
    else
        ids = properties.selected_events;
    end
    
    if ~isfield(properties, 'frames')
        out = zeros(events_info.height, events_info.width, ...
            events_info.nt, 'uint8');
    else
        out = properties.frames;
    end
    
    if ~isfield(properties, 'type')
        type = 'default';
    else
        type = properties.type;
    end
    
    if strcmp(type, 'default') || strcmp(type, 'points')
        points = events_3d.points(ids);
    elseif strcmp(type, 'smooth') || strcmp(type, 'spoints')
        points = events_3d.spoints(ids);
    elseif strcmp(type, 'border') || strcmp(type, 'border')
        points = events_3d.border(ids);
    end
    
    for j = 1:numel(points)
        x = int32(points{j}(:, 1));
        y = int32(points{j}(:, 2));
        t = int32(points{j}(:, 3));
        
        out(sub2ind(size(out), x, y, t)) = 128 + rem(ids(j) - 1, 128) + 1;
    end
end
