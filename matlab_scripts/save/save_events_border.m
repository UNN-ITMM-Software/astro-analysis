function [] = save_events_border(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving events border...');
    end
    
    %% Properties
    if ~isfield(properties, 'save_type')
        properties.save_type = 'mat';
    end
    if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
        properties.file_name = 'Events border';
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
%             if ~isfield(properties, 'file_name') || ...
%                     strcmp(properties.file_name, '')
%                 properties.file_name = 'events';
%             end
%             file_name = fullfile(properties.path, properties.file_name);
%             events_info = calculus.events_info;
%             events_3d = calculus.events_3d;
%             save(sprintf('%s.mat', file_name), ...
%                 'events_info', 'events_3d', '-v7.3');
        case {'png', 'eps'}
            
        case 'avi'
            
        case 'csv'
            events_info = calculus.events_info;
            events_3d = calculus.events_3d;
                    
            events_info = events_info(ids{:, 1});
            events_3d = events_3d(ids{:, 1});
            
            columns_names = {'id_events', 'x1', 'y1', 'x2', 'y2', 't'};
            num = 0;
            for i = 1:events_info.number
                border = events_3d.border{i};
                num = num + length(border_edges);
            end
            borders_segments = zeros(num, 6, 'int32');
            
            k = 1;
            for i = 1:events_info.number
                border = events_3d.border{i};
                border_edges = events_3d.border_edges{i};
                for j = 1:length(border_edges)
                    if border_edges(j, 3) < 485 || border_edges(j, 3) > 491
                        continue;
                    end
                    borders_segments(k, 1) = i;
                    borders_segments(k, 2) = border(border_edges(j,1), 1);
                    borders_segments(k, 3) = border(border_edges(j,1), 2);
                    borders_segments(k, 4) = border(border_edges(j,2), 1);
                    borders_segments(k, 5) = border(border_edges(j,2), 2);
                    borders_segments(k, 6) = border_edges(j, 3);
                    k = k + 1;
                end
            end
            borders_segments(k:end, :) = [];
            T = array2table(borders_segments);
            T.Properties.VariableNames = columns_names;
            writetable(T, sprintf('%s.csv', file_name), ...
                'delimiter', ';');
    end
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Events border saved.');
    end
end
