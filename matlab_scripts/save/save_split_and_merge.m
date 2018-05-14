function [] = save_split_and_merge(calculus, properties)
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving plot count split, merge and regions per frame...');
    end
    
    %% Properties
    id_algo = properties.id_algorithm;
    ids = get_ids(properties, calculus, id_algo);
    file_name = fullfile(properties.path, [properties.file_name]);
    save_type = properties.save_type;
    
    %% Loading data
    if ~isempty(whos(calculus, 'count_merge_per_frame'))
        count_merge_per_frame_cell = calculus.count_merge_per_frame;
    else
        add_info_log('count_merge_per_frame not found');
        return
    end
    if ~isempty(whos(calculus, 'count_split_per_frame'))
        count_split_per_frame_cell = calculus.count_split_per_frame;
    else
        add_info_log('count_split_per_frame not found');
        return
    end
    if ~isempty(whos(calculus, 'count_regions'))
        count_regions_cell = calculus.count_regions;
    else
        add_info_log('count_regions not found');
        return
    end
    ticks = calculus.ticks;
    variavle_table(:, 1) = ticks.time';
    VariableNames{1} = 'time';
    count = 2;
    
    %% save
    for id = ids
        if has_item(calculus, 'count_merge_per_frame', id, false)
            count_merge_per_frame = count_merge_per_frame_cell{id{:}}';
        else
            continue;
        end
        if has_item(calculus, 'count_split_per_frame', id, false)
            count_split_per_frame = count_split_per_frame_cell{id{:}}';
        else
            continue;
        end
        if has_item(calculus, 'count_regions', id, false)
            count_regions = count_regions_cell{id{:}};
        else
            continue;
        end
        variavle_table(:, count:count + 2) = ...
            [count_split_per_frame(:), count_merge_per_frame(:), count_regions(:)];
        %% Properties
        if id{2} == 1
            postfix = '_ITMM';
        elseif id{2} == 2
            postfix = '_YuWei';
        end
        VariableNames(count:count + 2) = ...
            {['count_split', postfix], ['count_merge', postfix], ['count_regions', postfix]};
        count = count + 3;
        if isequal(save_type, 'png') || isequal(save_type, 'eps')
            curproperties = properties;
            curproperties.visible = 0;
            curproperties.id_algorithm = id{2};
            fig = plot_split_and_merge(calculus, curproperties);
            save_fig(fig, [file_name, postfix], [0, 0, 16, 9], properties.save_type, false);
            close(fig);
        end
    end
    switch save_type
        case 'csv'
            T = array2table(variavle_table);
            T.Properties.VariableNames = VariableNames;
            writetable(T, sprintf('%s.csv', file_name), ...
                'delimiter', ';');
        case 'mat'
            save(sprintf('%s.mat', file_name), 'variavle_table');
            
    end
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Plot count split, merge and regions per frame saved.');
    end
end
