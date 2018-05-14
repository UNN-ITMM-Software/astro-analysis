function [calculus] = calc_shannon_entropy(calculus, properties)
    add_info_log('Calculating shannon entropy per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shannon_entropy'))
        if ~iscell(calculus.shannon_entropy)
            shannon_entropy = cell(size(events_info_cell));
            shannon_entropy{1, 1} = calculus.shannon_entropy;
        else
            shannon_entropy = calculus.shannon_entropy;
        end
    else
        shannon_entropy = cell(size(events_info_cell));
    end
    
    %% Calculate
    for id = ids
        events_info = events_info_cell(id{:});
        count_points = calculus.count_points(id{:});
        count_points = count_points{1};
        if isempty(count_points), continue;
        end
        shannon_entropy{id{:}} = zeros(events_info.nt, 1);
        for i = 1:events_info.nt
            p = double(count_points(i)) / ...
                double(events_info.height * events_info.width);
            shannon_entropy{id{:}}(i) = -xlogx(p) - xlogx(1 - p);
        end
    end
    
    %% Store data
    calculus.shannon_entropy = shannon_entropy;
    
    %%
    add_info_log('Shannon entropy per frame calculated.');
end
