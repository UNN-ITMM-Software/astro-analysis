function [calculus] = calc_shannon_entropy_from_ids(calculus, properties)
    add_info_log('Calculating Shannon entropy from ids...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shannon_entropy_from_ids'))
        if ~iscell(calculus.shannon_entropy_from_ids)
            shannon_entropy = cell(size(events_info_cell));
            shannon_entropy{1} = calculus.shannon_entropy_from_ids;
        else
            shannon_entropy = calculus.shannon_entropy_from_ids;
        end
    else
        shannon_entropy = cell(size(events_info_cell));
    end
    
    %% Calculate
    for id = ids
        events_info = calculus.events_info(id{:});
        count_points = calculus.count_points(id{:});
        count_points = count_points{1};
        if isempty(count_points), continue;
        end
        shannon_entropy{id{:}} = zeros(events_info.nt, 1);
        p = double(sum(count_points(:))) / ...
            double(events_info.nt * events_info.height * events_info.width);
        shannon_entropy{id{:}} = -xlogx(p) - xlogx(1 - p);
    end
    
    %% Store data
    calculus.shannon_entropy_from_ids = shannon_entropy;
    
    %%
    add_info_log('Shannon entropy from ids calculated.');
end
