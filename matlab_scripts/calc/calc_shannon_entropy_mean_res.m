function [calculus] = calc_shannon_entropy_mean_res(calculus, properties)
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
    if ~isempty(whos(calculus, 'shannon_entropy_mean_res'))
        if ~iscell(calculus.shannon_entropy_mean_res)
            shannon_entropy_mean_res = cell(size(events_info_cell));
            shannon_entropy_mean_alpha_res = cell(size(events_info_cell));
            shannon_entropy_mean_res{1, 1} = calculus.shannon_entropy_mean_res;
            shannon_entropy_mean_alpha_res{1, 1} = calculus.shannon_entropy_mean_alpha_res;
        else
            shannon_entropy_mean_res = calculus.shannon_entropy_mean_res;
            shannon_entropy_mean_alpha_res = calculus.shannon_entropy_mean_alpha_res;
        end
    else
        shannon_entropy_mean_res = cell(size(events_info_cell));
        shannon_entropy_mean_alpha_res = cell(size(events_info_cell));
    end
    
    %% Calculate
    shannon_entropy_res_ = calculus.shannon_entropy_diff_res;
    for id = ids
        shannon_entropy_diff_res = shannon_entropy_res_{id{:}};
        if ~isempty(shannon_entropy_diff_res)
            shannon_entropy_mean_res{id{:}} = mean(shannon_entropy_diff_res);
            shannon_entropy_mean_alpha_res{id{:}} = std(shannon_entropy_diff_res);
        end
    end
    
    %% Store data
    calculus.shannon_entropy_mean_alpha_res = shannon_entropy_mean_alpha_res;
    calculus.shannon_entropy_mean_res = shannon_entropy_mean_res;
    
    %%
    add_info_log('Shannon entropy diff per frame calculated.');
end
