function [] = save_correlation_all(calculus, properties)
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving all corelation...');
    end
    
    %% properties
    id_algo = properties.id_algorithm;
    save_type = properties.save_type;
    ids = get_ids(properties, calculus, id_algo);
    
    %% Loading data
    if ~isempty(whos(calculus, 'correlations_all'))
        corr_cell = calculus.correlations_all;
    else
        add_info_log(['correlations_all', ' not found']);
        return;
    end
    arr_variable = {'percent_luminescence_frame', 'count_regions', ...
        'count_merge_per_frame', 'count_split_per_frame', 'count_events', ...
        'compactness_index_frame', ...
        'average_events_area', 'average_regions_area'};
    arr_variable_name_table = {'PL', '\#R', '\#M', '\#S', '\#E', 'CI', ...
        '$\langle E \rangle$', '$\langle R \rangle$'};
    for id = ids
        k = 1;
        cor = [];
        if has_item(calculus, 'correlations_all', id, false)
            corr = corr_cell{id{:}};
        else
            continue;
        end
        for i = 1:length(arr_variable)
            if ~isempty(whos(calculus, arr_variable{i}))
                variable_1_cell = calculus.(arr_variable{i});
            else
                add_info_log([arr_variable{i}, ' not found']);
                continue;
            end
            if has_item(calculus, arr_variable{i}, id, false)
                variable_1 = variable_1_cell{id{:}};
            else
                continue;
            end
            arr_variable_name(k) = arr_variable(i);
            variable_all{k} = variable_1(:);
            variable_all_names{k} = arr_variable_name_table{i};
            k = k + 1;
            for j = 1:length(arr_variable)
                if ~isempty(whos(calculus, arr_variable{j}))
                    variable_2_cell = calculus.(arr_variable{j});
                else
                    add_info_log([arr_variable{j}, ' not found']);
                    continue;
                end
                if has_item(calculus, arr_variable{j}, id, false)
                    variable_2 = variable_2_cell{id{:}};
                else
                    continue;
                end
                if id{2} == 1
                    properties.file_name = ['correlation_', arr_variable{i}, '_vs_', arr_variable{j}, '_(ITMM)'];
                elseif id{2} == 2
                    properties.file_name = ['correlation_', arr_variable{i}, '_vs_', arr_variable{j}, '_(Yu Wei)'];
                end
                file_name1 = fullfile(properties.path, properties.file_name);
                if id{2} == 1
                    properties.file_name = ['correlation_', arr_variable{i}, '_and_', arr_variable{j}, '_(ITMM)'];
                elseif id{2} == 2
                    properties.file_name = ['correlation_', arr_variable{i}, '_and_', arr_variable{j}, '_(Yu Wei)'];
                end
                file_name2 = fullfile(properties.path, properties.file_name);
                cor(i, j) = corr.([arr_variable{i}, '_vs_', arr_variable{j}]);
                switch save_type
                    case {'png', 'eps'}
                        curproperties = properties;
                        curproperties.visible = 0;
                        curproperties.id_algorithm = id{2};
                        curproperties.variable = [double(variable_1(:)), double(variable_2(:))];
                        curproperties.corr = corr.([arr_variable{i}, '_vs_', arr_variable{j}]);
                        curproperties.variable_name(1:2) = ...
                            {arr_variable{i}, arr_variable{j}};
                        fig = plot_correlation_coefficients(calculus, curproperties, id{2});
                        save_fig(fig, file_name1, [0, 0, 9, 9], properties.save_type, false);
                        close(fig);
                        fig = plot_correlation_coefficients_double(calculus, curproperties, id{2});
                        save_fig(fig, file_name2, [0, 0, 16, 9], properties.save_type, false);
                        close(fig);
                end
            end
        end
        if id{2} == 1
            properties.file_name = 'correlation_table_(ITMM)';
        elseif id{2} == 2
            properties.file_name = 'correlation_table_(Yu Wei)';
        end
        file_name = fullfile(properties.path, properties.file_name);
        T = array2table(cor);
        T.Properties.VariableNames = arr_variable_name;
        T.Properties.RowNames = arr_variable_name';
        switch save_type
            case {'png', 'eps'}
                curproperties = properties;
                curproperties.visible = 0;
                curproperties.id_algorithm = id{2};
                curproperties.variable_all = variable_all;
                curproperties.variable_names = variable_all_names;
                fig = plot_correlation_coefficients_table(calculus, curproperties, id{2});
                save_fig(fig, file_name, [0, 0, 16, 18], properties.save_type, false);
                close(fig);
            case {'csv'}
                writetable(T, sprintf('%s.csv', file_name), ...
                    'delimiter', ';');
            case {'mat'}
                save(sprintf('%s.mat', file_name), 'T');
        end
    end
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saved plot correlation all.');
    end
end
