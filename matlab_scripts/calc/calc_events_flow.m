function [calculus] = calc_events_flow(calculus, properties)
    add_info_log('Calculating events flow...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isempty(whos(calculus, 'events_info')) && ...
            ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        events_3d_cell = calculus.events_3d;
        
        %% Loading data
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            MAX_SPEED = properties.MAX_SPEED;
            
            events_3d.to = cell(events_info.number, 1);
            for s = 1:events_info.number
                events_3d.to{s} = zeros(size(events_3d.border{s}, 1), 1, 'int32');
                events_3d.from{s} = zeros(size(events_3d.border{s}, 1), 1, 'int32');
            end
            for k = 2:events_info.nt
                add_info_log('Calculating events flow...', k / events_info.nt);
                for s = 1:events_info.number
                    %if s ~= 464 || k ~= 487
                    %    continue;
                    %end
                    data = events_3d.border{s};
                    
                    p_prev = data(data(:, 3) == k - 1, [1, 2]);
                    p_cur = data(data(:, 3) == k, [1, 2]);
                    
                    if isempty(p_prev) || isempty(p_cur)
                        continue;
                    end
                    
                    n = size(p_cur, 1);
                    m = size(p_prev, 1);
                    count_operations = min(n, m)^2 * max(n, m);
                    if count_operations < 1e10
                        W = pdist2(double(p_cur), double(p_prev));
                        if size(W, 1) > size(W, 2)
                            W = W.';
                            need_swap = false;
                        else
                            need_swap = true;
                        end
                        [M1, I1] = min(W, [], 1);
                        [M2, ~] = min(W, [], 2);
                        
                        W = W - repmat(M1, size(W, 1), 1) - repmat(M2, 1, size(W, 2));
                        rowsol = hungarian(W).'; % length(rowsol) == size(W, 1)
                        colsol = zeros(1, size(W, 2)); % length(colsol) == size(W, 2)
                    else
                        need_swap = true;
                        rowsol = knnsearch(double(p_prev), double(p_cur))';
                        I1 = knnsearch(double(p_cur), double(p_prev))';
                        colsol = zeros(1, m);
                    end
                    colsol(rowsol) = 1;
                    
                    [k_prev, k_cur] = deal(1:length(rowsol), rowsol);
                    [k_prev, k_cur] = deal([k_prev, I1(colsol == 0)], [k_cur, find(~colsol)]);
                    
                    if need_swap %length(rowsol) ~= size(p_prev, 1)
                        [k_prev, k_cur] = deal(k_cur, k_prev);
                    end
                    
                    dx = p_cur(k_cur, 1) - p_prev(k_prev, 1);
                    dy = p_cur(k_cur, 2) - p_prev(k_prev, 2);
                    real_ids = hypot(double(dx), double(dy)) <= MAX_SPEED;
                    
                    shift_prev = find(data(:, 3) == k - 1, 1);
                    shift_cur = find(data(:, 3) == k, 1);
                    
                    events_3d.to{s}(k_prev(real_ids) + shift_prev - 1) = k_cur(real_ids) + shift_cur - 1;
                    events_3d.from{s}(k_cur(real_ids) + shift_cur - 1) = k_prev(real_ids) + shift_prev - 1;
                    %return;
                end
            end
            events_3d_cell = upd_struct(events_3d, events_3d_cell, id);
        end
        calculus.events_info = events_info_cell;
        calculus.events_3d = events_3d_cell;
    end
    add_info_log('Events flow calculated.');
end
