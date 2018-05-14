function [calculus] = calc_shanon_entropy_configurations(calculus, properties)
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
    if ~isempty(whos(calculus, 'configurations'))
        configurations_cell = calculus.configurations;
    else
        add_info_log('configurations not found');
        return
    end
    %ids = {{1,1},{2,1}};
    
    %% Declaration of variables
    if ~isempty(whos(calculus, 'shanon_entropy_configurations'))
        if ~iscell(calculus.shanon_entropy_configurations)
            shanon_entropy_configurations = cell(size(events_info_cell));
            shanon_entropy_configurations{1} = calculus.shanon_entropy_configurations;
        else
            shanon_entropy_configurations = calculus.shanon_entropy_configurations;
        end
    else
        shanon_entropy_configurations = cell(size(events_info_cell));
    end
    
    %% Calculate
    for id = ids
        if has_item(calculus, 'events_info', id, true)
            events_info = events_info_cell(id{:});
        else
            continue;
        end
        if has_item(calculus, 'configurations', id, false)
            configurations = configurations_cell{id{:}};
        else
            continue;
        end
        if isempty(configurations), continue;
        end
        Sum_config = sum(configurations(:));
        shanon_entropy_configurations{id{:}} = ...
            sum(-xlogx(double(configurations(:)) / double(Sum_config)));
    end
    
    %% Store data
    calculus.shanon_entropy_configurations = shanon_entropy_configurations;
    
    %%
    add_info_log('Shannon entropy from ids calculated.');
end
