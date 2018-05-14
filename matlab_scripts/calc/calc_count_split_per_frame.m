function [calculus] = calc_count_split_per_frame(calculus, properties)
    add_info_log('Calculating count split of events regions per frame...');
    
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
        count_split_cell = calculus.count_split;
        
        %% Declaration of variables
        if ~isempty(whos(calculus, 'count_split_per_frame'))
            if ~iscell(calculus.count_split_per_frame)
                count_split_per_frame = cell(size(events_info_cell));
                count_split_per_frame{1} = calculus.count_split_per_frame;
            else
                count_split_per_frame = calculus.count_split_per_frame;
            end
        else
            count_split_per_frame = cell(size(events_info_cell));
        end
        
        %% Calculate
        for id = ids
            events_info = events_info_cell(id{:});
            count_split = count_split_cell{id{:}};
            count_split_per_frame{id{:}} = zeros(1, events_info.nt, 'int32');
            count_split_per_frame{id{:}} = sum(count_split(:, :));
        end
        
        %% Store data
        calculus.count_split_per_frame = count_split_per_frame;
        
        %%
        add_info_log('Count split of events regions per frame calculated.');
    end
