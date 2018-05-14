function [calculus] = calc_count_merge_per_frame(calculus, properties)
    add_info_log('Calculating count merge of events regions per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Loading data
    if ~isempty(whos(calculus, 'events_info')) && ~isempty(whos(calculus, 'events_3d'))
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        count_merge_cell = calculus.count_merge;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'count_merge_per_frame'))
            if ~iscell(calculus.count_merge_per_frame)
                count_merge_per_frame = cell(size(events_info_cell));
                count_merge_per_frame{1} = calculus.count_merge_per_frame;
            else
                count_merge_per_frame = calculus.count_merge_per_frame;
            end
        else
            count_merge_per_frame = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            count_merge = count_merge_cell{id{:}};
            count_merge_per_frame{id{:}} = zeros(1, events_info.nt, 'int32');
            count_merge_per_frame{id{:}} = sum(count_merge(:, :));
        end
        
        %% Store data
        calculus.count_merge_per_frame = count_merge_per_frame;
        
    end
    
    %%
    add_info_log('Count merge of events regions per frame calculated.');
end
