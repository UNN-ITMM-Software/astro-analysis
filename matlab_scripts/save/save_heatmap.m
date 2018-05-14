function [] = save_heatmap(calculus, properties)
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Saving ', properties.full_name, '...']);
    end
    
    %% Properties
    id_algo = properties.id_algorithm;
    if isempty(id_algo)
        id_algo = [1];
    end
    if ~isfield(properties, 'save_type')
        properties.save_type = 'mat';
    end
    ids = get_ids(properties, calculus, id_algo);
    
    %% Loading data
    if is_created(calculus, properties.variable)
        variables = calculus.(properties.variable);
    else
        add_info_log([properties.variable, ' not found']);
        return
    end
    rescale_info = rescale_variable(calculus, properties);
    ticks = calculus.ticks;
    
    %% data preparation
    STREP(rescale_info.new_units{2}, [{'$'}, {'('}, {')'}], {''});
    unit = {rescale_info.new_units{1}, rescale_info.new_units{2}, rescale_info.new_units{3}{1}};
    variable_unit(1, 1:3) = STREP(unit, [{'$'}, {'('}, {')'}], {''});
    variable_unit(ticks.height + 1, 1:3) = repmat({''}, length(ticks.height), 3);
    for id = ids
        if iscell(variables)
            if has_item(calculus, properties.variable, id, false)
                variable = variables{id{:}};
            else
                continue
            end
        else
            variable = variables;
        end
        if isempty(properties.id_algorithm)
            postfix = '';
        else
            if id{2} == 1
                postfix = ' (ITMM)';
            else if id{2} == 2
                    postfix = ' (Yu Wei)';
                end
            end
        end
        
        file_name = fullfile(properties.path, [properties.file_name, ' ', postfix]);
        
        %% Saved
        switch properties.save_type
            case 'csv'
                VariableNames(1:4) = {'height_unit', 'width_unit', 'value_unit', 'height'};
                width = length(ticks.width);
                VariableNames(ticks.width + 4) = cellstr([repmat(['width'], width, 1), int2str([(1:width)'])])';
                ticks.width = ticks.width * rescale_info.new_coef(1);
                ticks.height = ticks.height * rescale_info.new_coef(2);
                variable_csv = [[0; ticks.height'], [ticks.width; rescale_info.new_coef(3) * variable]];
                T = [array2table(variable_unit), array2table(variable_csv)];
                T.Properties.VariableNames = STREP(VariableNames, ' ', '');
                writetable(T, sprintf('%s.csv', file_name), ...
                    'delimiter', ';');
            case 'mat'
                variable_mat.value = rescale_info.new_coef(3) * variable;
                variable_mat.units = variable_unit;
                variable_mat.ticks.width = ticks.width * rescale_info.new_coef(1);
                variable_mat.ticks.height = ticks.height * rescale_info.new_coef(2);
                save(sprintf('%s.mat', file_name), 'variable_mat');
            case {'png', 'eps'}
                curproperties = properties;
                curproperties.visible = 0;
                curproperties.id_algorithm = id{2};
                fig = plot_heatmap(calculus, curproperties);
                save_fig(fig, file_name, [0, 0, 10, 7], properties.save_type, false);
                close(fig);
        end
    end
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log([properties.full_name, ' saved.']);
    end
end
