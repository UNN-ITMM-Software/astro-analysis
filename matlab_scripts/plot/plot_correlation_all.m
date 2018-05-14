function [fig] = plot_correlation_all(calculus, properties)
    if ~isempty(whos(calculus, 'correlations_all'))
        corr_cell = calculus.correlations_all;
    else
        add_info_log(['correlations_all', ' not found']);
        return;
    end
    prompt = {'Enter type plot', 'Enter number variable 1', 'Enter number variable 2'};
    title = 'Correlation';
    dims = [1, 35];
    definput = {'1', '1', '1'};
    answ = inputdlg(prompt, title, dims, definput);
    answer(1) = str2double(answ(1));
    if answer(1) < 1 || answer(1) > 3
        add_info_log('incorrect type plot is specified')
        return
    end
    answer(2) = str2double(answ(2));
    answer(3) = str2double(answ(3));
    if answer(2) < 1 || answer(2) > 8 || answer(3) < 1 || answer(3) > 8
        add_info_log('incorrect variable plot is specified')
        return
    end
    
    if ~isempty(answer)
        id_algo = properties.id_algorithm;
        ids = get_ids(properties, calculus, id_algo);
        
        %% Loading data
        
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
            if answer(1) > 1
                if ~isempty(whos(calculus, arr_variable{answer(2)}))
                    variable_1_cell = calculus.(arr_variable{answer(2)});
                else
                    add_info_log([arr_variable{answer(2)}, ' not found']);
                    continue;
                end
                if has_item(calculus, arr_variable{answer(2)}, id, false)
                    variable_1 = variable_1_cell{id{:}};
                else
                    continue;
                end
                if ~isempty(whos(calculus, arr_variable{answer(3)}))
                    variable_2_cell = calculus.(arr_variable{answer(3)});
                else
                    add_info_log([arr_variable{answer(3)}, ' not found']);
                    continue;
                end
                if has_item(calculus, arr_variable{answer(3)}, id, false)
                    variable_2 = variable_2_cell{id{:}};
                else
                    continue;
                end
                curproperties = properties;
                curproperties.visible = 1;
                curproperties.id_algorithm = id{2};
                curproperties.variable = [double(variable_1(:)), double(variable_2(:))];
                curproperties.corr = corr.([arr_variable{answer(2)}, '_vs_', arr_variable{answer(3)}]);
                curproperties.variable_name(1:2) = ...
                    {arr_variable{answer(2)}, arr_variable{answer(3)}};
                if answer(1) == 2
                    plot_correlation_coefficients(calculus, curproperties, id{2});
                elseif answer(1) == 3
                    fig = plot_correlation_coefficients_double(calculus, curproperties, id{2});
                end
                
            else
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
                    variable_all{k} = variable_1(:);
                    variable_all_names{k} = arr_variable_name_table{i};
                    k = k + 1;
                end
                
                if answer(1) == 1
                    curproperties = properties;
                    curproperties.visible = 1;
                    curproperties.id_algorithm = id{2};
                    curproperties.variable_all = variable_all;
                    curproperties.variable_names = variable_all_names;
                    fig = plot_correlation_coefficients_table(calculus, curproperties, id{2});
                end
                
            end
        end
    end
    
    %%
end