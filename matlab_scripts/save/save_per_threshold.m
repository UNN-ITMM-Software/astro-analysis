function [] = save_per_threshold(calculus, properties)
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving shannon entropy per frame...');
    end
    
    %% Properties
    id_algo = properties.id_algorithm;
    file_name = fullfile(properties.path, [properties.file_name]);
    save_type = properties.save_type;
    ids = get_ids(properties, calculus, id_algo);
    
    %% load data
    rescale_info = rescale_variable(calculus, properties);
    if ~isempty(whos(calculus, properties.variable))
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    thresholds = calculus.thresholds;
    
    %% data preparation
    VariableNames(1:2) = {'thresholds_number', 'thresholds_value'};
    variavle_table(1, 1:3) = {'', '', STREP(rescale_info.new_units{2}, [{'$'}, {'('}, {')'}], {''})};
    if id_algo(1) == 1
        for i = 1:length(thresholds)
            variavle_table(i + 2, 1:3) = {i, thresholds(i), ''};
        end
    end
    if length(id_algo) > 1
        variavle_table(1, 4) = variavle_table(1, 3);
        variavle_table(2:length(thresholds) + 1, 4) = repmat({''}, length(thresholds), 1);
    end
    count = 3;
    for id = ids
        if has_item(calculus, properties.variable, id, false)
            variable = variables{id{:}};
        else
            continue
        end
        if id{2} == 1
            variavle_table{id{1} + 1, 3} = rescale_info.new_coef(2) * variable(:);
            VariableNames{3} = 'ITMM';
            count = count + 1;
        else if id{2} == 2
                variavle_table{id{1} + 1, count} = rescale_info.new_coef(2) * variable(:);
                VariableNames{count} = 'YuWei';
            end
        end
    end
    T = array2table(variavle_table);
    T.Properties.VariableNames = VariableNames;
    
    %% Saved
    switch save_type
        case 'csv'
            writetable(T, sprintf('%s.csv', file_name), ...
                'delimiter', ';');
        case 'mat'
            save(sprintf('%s.mat', file_name), 'T');
        case {'png', 'eps'}
            fig = plot_per_threshold(calculus, ...
                setfield(properties, 'visible', 0));
            save_fig(fig, file_name, [0, 0, 16, 9], properties.save_type, false);
            close(fig);
    end
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' saved.']);
    end
end
