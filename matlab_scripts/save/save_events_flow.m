function [] = save_events_flow(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving events flow...');
    end
    
    %% Properties
    if ~isfield(properties, 'save_type')
        properties.save_type = 'mat';
    end
    if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
        properties.file_name = 'Events flow';
    end
    
    id_algo = properties.id_algorithm;
    if length(id_algo) == 2
        postfix = '(Yu Wei) and (ITMM)';
    else
        if id_algo == 1
            postfix = '(ITMM)';
        else if id_algo == 2
                postfix = '(Yu Wei)';
            end
        end
    end
    file_name = fullfile(properties.path, [properties.file_name, ' ', postfix]);
    save_type = properties.save_type;
    ids = get_ids(properties, calculus, id_algo);
    
    switch save_type
        case 'mat'
            if ~isfield(properties, 'file_name') || ...
                    strcmp(properties.file_name, '')
                properties.file_name = 'events';
            end
            file_name = fullfile(properties.path, properties.file_name);
            events_info = calculus.events_info;
            events_3d = calculus.events_3d;
            save(sprintf('%s.mat', file_name), ...
                'events_info', 'events_3d', '-v7.3');
        case {'png', 'eps'}
            
        case 'avi'
            
        case 'csv'
            events_info = calculus.events_info;
            events_3d = calculus.events_3d;
                    
            events_info = events_info(ids{:, 1});
            events_3d = events_3d(ids{:, 1});
            
            columns_names = {'id_events', 'x', 'y', 't', 'u', 'v', 'w'};
            num = 0;
            for i = 1:events_info.number
                border = events_3d.border{i};
                num = num + length(border) * 2;
            end
            flow = zeros(num, 7, 'int32');
            
            k = 1;
            for i = 1:events_info.number
                border = events_3d.border{i};
                to = events_3d.to{i};
                from = events_3d.from{i};
                for j = 1:length(border)
                    if border(j, 3) < 485 || border(j, 3) > 491
                        continue;
                    end
                    if to(j) ~= 0
                        flow(k, 1) = i;
                        flow(k, 2) = border(j, 1);
                        flow(k, 3) = border(j, 2);
                        flow(k, 4) = border(j, 3);
                        
                        flow(k, 5) = int32(border(to(j), 1)) - int32(border(j, 1));
                        flow(k, 6) = int32(border(to(j), 2)) - int32(border(j, 2));
                        flow(k, 7) = int32(border(to(j), 3)) - int32(border(j, 3));
                        k = k + 1;
                    end
                end
                for j = 1:length(border)
                    if border(j, 3) < 485 || border(j, 3) > 491
                        continue;
                    end
                    if from(j) ~= 0
                        flow(k, 1) = i;
                        flow(k, 2) = border(from(j), 1);
                        flow(k, 3) = border(from(j), 2);
                        flow(k, 4) = border(from(j), 3);
                    
                        flow(k, 5) = int32(border(j, 1)) - int32(border(from(j), 1));
                        flow(k, 6) = int32(border(j, 2)) - int32(border(from(j), 2));
                        flow(k, 7) = int32(border(j, 3)) - int32(border(from(j), 3));
                        k = k + 1;
                    end
                end
            end
            flow(k:end, :) = [];
            T = array2table(flow);
            T.Properties.VariableNames = columns_names;
            writetable(T, sprintf('%s.csv', file_name), ...
                'delimiter', ';');
    end
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Events flow saved.');
    end
end
