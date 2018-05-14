function [calculus] = calc_events_regions_graph(calculus, properties)
    add_info_log('Calculating graph of events regions...');
    
    %% Properties
    id_algo = properties.id_algorithm;
    
    %% Load data
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        events_3d_cell = calculus.events_3d;
        for id = ids
            
            %% Load data
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            events_3d.centroids = cell(events_info.number, 1);
            events_3d.edges = cell(events_info.number, 1);
            events_3d.components = cell(events_info.number, 1);
            events_3d.components_ptr = cell(events_info.number, 1);
            
            % Split events on components
            for s = 1:events_info.number
                add_info_log('Split events on components...', double(s) / double(events_info.number));
                border = events_3d.border{s};
                to = events_3d.to{s};
                b_ptr = get_ptr(border(:, 3));
                for k = 1:(length(b_ptr) - 1)
                    v_cur = border(b_ptr(k):(b_ptr(k + 1) - 1), 1:2);
                    if (isempty(v_cur))
                        continue;
                    end
                    
                    cut = connected_cut(int16(v_cur));
                    
                    v_cur = v_cur(cut(:, 1), 1:2);
                    border(b_ptr(k):(b_ptr(k + 1) - 1), 1:2) = v_cur;
                    
                    to_cur = to(b_ptr(k):(b_ptr(k + 1) - 1));
                    to(b_ptr(k):(b_ptr(k + 1) - 1)) = to_cur(cut(:, 1));
                    
                    if isempty(events_3d.components{s})
                        events_3d.components{s} = cut(:, 2);
                    else
                        mx = events_3d.components{s}(end);
                        events_3d.components{s} = ...
                            [events_3d.components{s}; cut(:, 2) + mx];
                    end
                end
                events_3d.border{s} = border;
                events_3d.to{s} = to;
            end
            
            %% Calculate pointers to components, centroids and edges
            for s = 1:events_info.number
                add_info_log('Calculating centroids and edges...', double(s) / double(events_info.number));
                cc = events_3d.components{s};
                cc_ptr = get_ptr(cc);
                
                events_3d.components_ptr{s} = cc_ptr;
                events_3d.centroids{s} = zeros(length(cc_ptr) - 1, 3);
                events_3d.edges{s} = cell(length(cc_ptr) - 1, 1);
                
                to = events_3d.to{s};
                border = events_3d.border{s};
                for i = 1:(length(cc_ptr) - 1)
                    points = border(cc_ptr(i):(cc_ptr(i + 1) - 1), :);
                    events_3d.centroids{s}(i, :) = mean(points, 1);
                    to_cur = to(cc_ptr(i):(cc_ptr(i + 1) - 1));
                    events_3d.edges{s}{i} = unique(cc(to_cur(to_cur > 0)));
                end
            end
            events_info_cell(id{:}) = events_info;
            events_3d_cell = upd_struct(events_3d, events_3d_cell, id);
        end
        
        %% Store data
        calculus.events_info = events_info_cell;
        calculus.events_3d = events_3d_cell;
    end
    
    %%
    add_info_log('Graph of events regions calculated.');
end

function [cut] = connected_cut(p)
    n = size(p, 1);
    s = [];
    t = [];
    
    for dx = -1:1
        for dy = -1:1
            if dx == 0 && dy == 0
                continue;
            end
            [v1, v2] = get_edges(p, int16([dx, dy]));
            s = [s; v1];
            t = [t; v2];
        end
    end
    for i = 1:length(s)
        if s(i) > t(i)
            [t(i), s(i)] = deal(s(i), t(i));
        end
    end
    
    [Q] = unique([t, s], 'rows');
    s = Q(:, 1)';
    t = Q(:, 2)';
    
    g = graph(s, t, [], n);
    bins = conncomp(g);
    cut = int32(sortrows([1:n; bins].', 2));
end

function [from, to] = get_edges(p, v)
    n = size(p, 1);
    q = p + repmat(v, n, 1);
    [~, to, from] = intersect(p, q, 'rows');
end

function [ptr] = get_ptr(data)
    [~, ia, ~] = unique(data);
    ptr = int32([ia; size(data, 1) + 1]);
end
