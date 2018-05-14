function [calculus] = calc_integrated_information_res(calculus, properties)
    add_info_log('Calculating integrated information resize...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    events_info_cell = calculus.events_info;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Load data
    if ~isempty(whos(calculus, 'configurations_res'))
        configurations_cell = calculus.configurations_res;
    else
        add_info_log('configurations_res not found');
        return
    end
    if ~isempty(whos(calculus, 'configurations_merge_res'))
        configurations_merge_cell = calculus.configurations_merge_res;
    else
        add_info_log('configurations_merge_res not found');
        return
    end
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'integrated_information_res'))
        if ~iscell(calculus.integrated_information_res)
            integrated_information = cell(size(events_info_cell));
            integrated_information{1, 1} = calculus.integrated_information_res;
        else
            integrated_information = calculus.integrated_information_res;
        end
    else
        integrated_information = cell(size(events_info_cell));
    end
    
    %% Calculate
    k = 0;
    add_info_log('Calculating configurations...', 0);
    for id = ids
        ENTROPY_WINDOW_SIZE = 3;
        events_info = events_info_cell(id{:});
        if has_item(calculus, 'configurations_res', id, false)
            configurations = configurations_cell{id{:}};
        else
            continue;
        end
        if has_item(calculus, 'configurations_merge_res', id, false)
            configurations_merge = configurations_merge_cell{id{:}};
        else
            continue;
        end
        
        Nx = ENTROPY_WINDOW_SIZE^2;
        Nxy = 2 * ENTROPY_WINDOW_SIZE^2;
        Mx = sum(configurations);
        Mxy = sum(configurations_merge);
        integrated_information{id{:}} = ...
            compute_integrated_information(configurations, ...
            configurations_merge, Mx, Mxy, Nx, Nxy);
        
        k = k + 1;
        add_info_log('Calculating integrated information...', ...
            double(k) / length(ids));
    end
    
    %% Store data
    calculus.integrated_information_res = integrated_information;
    
    %%
    add_info_log('Integrated information resize calculated.');
end
