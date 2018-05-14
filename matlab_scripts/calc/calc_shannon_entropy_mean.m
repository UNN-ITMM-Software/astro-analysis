function [calculus] = calc_shannon_entropy_mean(calculus, properties)
    add_info_log('Calculating shannon entropy mean...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shannon_entropy_mean'))
        if ~iscell(calculus.shannon_entropy_mean)
            shannon_entropy_mean = cell(size(events_info_cell));
            shannon_entropy_mean_alpha = cell(size(events_info_cell));
            shannon_entropy_mean{1, 1} = calculus.shannon_entropy_mean;
            shannon_entropy_mean_alpha{1, 1} = calculus.shannon_entropy_mean_alpha;
        else
            shannon_entropy_mean = calculus.shannon_entropy_mean;
            shannon_entropy_mean_alpha = calculus.shannon_entropy_mean_alpha;
        end
    else
        shannon_entropy_mean = cell(size(events_info_cell));
        shannon_entropy_mean_alpha = cell(size(events_info_cell));
    end
    
    %% Calculate
    shannon_entropy_ = calculus.shannon_entropy_diff;
    for id = ids
        shannon_entropy_diff = shannon_entropy_{id{:}};
        if ~isempty(shannon_entropy_diff)
            shannon_entropy_mean{id{:}} = mean(shannon_entropy_diff);
            shannon_entropy_mean_alpha{id{:}} = std(shannon_entropy_diff);
        end
    end
    
    %% Store data
    calculus.shannon_entropy_mean_alpha = shannon_entropy_mean_alpha;
    calculus.shannon_entropy_mean = shannon_entropy_mean;
    
    %%
    add_info_log('Shannon entropy diff per frame calculated.');
end
