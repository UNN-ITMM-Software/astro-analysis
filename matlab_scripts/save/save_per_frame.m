function [] = save_per_frame(calculus, properties)
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Saving ', properties.full_name, '...']);
    end
    
    %% Properties
    id_algo = properties.id_algorithm;
    if length(id_algo) == 2
        postfix = ' (Yu Wei) and (ITMM)';
    else
        if id_algo == 1
            postfix = ' (ITMM)';
        else if id_algo == 2
                postfix = ' (Yu Wei)';
            end
        end
    end
    file_name = fullfile(properties.path, [properties.file_name, ' ', postfix]);
    save_type = properties.save_type;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Loading data
    rescale_info = rescale_variable(calculus, properties);
    if ~isempty(whos(calculus, properties.variable))
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    ticks = calculus.ticks;
    
    %% data preparation
    variavle_units{1} = STREP(rescale_info.new_units{1}, [{'$'}, {'('}, {')'}], {''});
    for i = 1:length(ticks.time)
        variavle_table{i, 1} = ticks.time(i) * rescale_info.new_coef(1);
    end
    VariableNames{1} = 'time';
    count = 1;
    for id = ids
        if has_item(calculus, properties.variable, id, false)
            variable = variables{id{:}};
        else
            continue
        end
        count = count + 1;
        variavle_units{count} = STREP(rescale_info.new_units{2}, [{'$'}, {'('}, {')'}], {''});
        for i = 1:length(ticks.time)
            variavle_table{i, count} = variable(i) * rescale_info.new_coef(2);
        end
        if id{2} == 1
            postfix = '_ITMM';
            if id{1} > 1, postfix = ['_ITMM_', int2str(id{1})];
            end
        else if id{2} == 2
                postfix = '_YuWei';
            end
        end
        VariableNames{count} = [properties.variable, postfix];
    end
    
    %% Save
    switch save_type
        case 'csv'
            T = array2table([variavle_units; variavle_table]);
            T.Properties.VariableNames = VariableNames;
            writetable(T, sprintf('%s.csv', file_name), ...
                'delimiter', ';');
        case 'mat'
            variable_mat.value = variavle_table;
            variable_mat.units = variavle_units;
            variable_mat.name = VariableNames;
            save(sprintf('%s.mat', file_name), 'variable_mat');
        case {'png', 'eps'}
            curproperties = properties;
            curproperties.visible = 0;
            fig = plot_per_frame(calculus, curproperties);
            save_fig(fig, file_name, [0, 0, 16, 9], properties.save_type, false);
            close(fig);
    end
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' saved.']);
    end
end
