function [calculus] = calc_shanon_entropy_configurations_res(calculus, properties)
    add_info_log('Calculating shannon entropy from ids...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    ids = get_ids(properties, calculus, id_algo);
    if ~isempty(whos(calculus, 'configurations_res'))
        configurations_cell = calculus.configurations_res;
    else
        add_info_log('configurations_res not found');
        return
    end
    %ids = {{1,1},{2,1}};
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shanon_entropy_configurations_res'))
        if ~iscell(calculus.shanon_entropy_configurations_res)
            shanon_entropy_configurations_res = cell(size(events_info_cell));
            shanon_entropy_configurations_res{1} = calculus.shanon_entropy_configurations_res;
        else
            shanon_entropy_configurations_res = calculus.shanon_entropy_configurations_res;
        end
    else
        shanon_entropy_configurations_res = cell(size(events_info_cell));
    end
    
    %% Calculate
    for id = ids
        if has_item(calculus, 'configurations_res', id, false)
            configurations_res = configurations_cell{id{:}};
        else
            continue;
        end
        if isempty(configurations_res), continue;
        end
        Sum_config = sum(configurations_res(:));
        shanon_entropy_configurations_res{id{:}} = ...
            sum(-xlogx(double(configurations_res(:)) / double(Sum_config)));
    end
    
    %% Store data
    calculus.shanon_entropy_configurations_res = shanon_entropy_configurations_res;
    
    %%
    add_info_log('Shannon entropy from ids calculated.');
end
