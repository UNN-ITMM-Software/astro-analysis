function calculus = calc_smooth_border(calculus, properties)
    add_info_log('Calculating smooth border of events...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        
        %% Load data
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        events_3d_cell = calculus.events_3d;
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            events_3d.spoints = cell(events_info.number, 1);
            events_3d.border = cell(events_info.number, 1);
            
            for k = 1:events_info.nt
                add_info_log('Calculating smooth border of events...', ...
                    double(k) / double(events_info.nt));
                for s = 1:events_info.number
                    data = events_3d.points{s};
                    spoints = events_3d.spoints{s};
                    border = events_3d.border{s};
                    
                    v_cur = data(data(:, 3) == k, 1:2);
                    if isempty(v_cur)
                        continue;
                    end
                    
                    L = uint8(zeros(events_info.height, events_info.width));
                    L(sub2ind(size(L), v_cur(:, 1), v_cur(:, 2))) = 1;
                    L = smooth_event(L);
                    
                    [I, J] = ind2sub(size(L), find(L));
                    spoints = [spoints; uint16([I, J, repmat(k, length(I), 1)])];
                    events_3d.spoints{s} = spoints;
                    
                    B = int8(bwperim(L));
                    
                    [I, J] = ind2sub(size(B), find(B));
                    border = [border; uint16([I, J, repmat(k, length(I), 1)])];
                    events_3d.border{s} = border;
                end
            end
            events_3d_cell = upd_struct(events_3d, events_3d_cell, id);
        end
        
        %% Store data
        calculus.events_info = events_info_cell;
        calculus.events_3d = events_3d_cell;
    end
    add_info_log('Smooth border of events calculated.');
end

function [S] = smooth_event(L)
    se = strel('disk', 4);
    S = imclose(imopen(L, se), se);
    S = imfill(S, 'holes');
end
