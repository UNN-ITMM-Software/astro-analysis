function [] = save_configurations(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving configurations...');
    end
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Loading data
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    if length(id_algo) == 1
        if id_algo == 1
            properties.file_name = 'configurations (ITMM)';
        else if id_algo == 2
                properties.file_name = 'configurations (Yu Wei)';
            end
        end
    else
        properties.file_name = 'configurations (ITMM) and (Yu Wei)';
    end
    file_name = fullfile(properties.path, properties.file_name);
    ids = get_ids(events_info_cell, id_algo);
    if ~isempty(whos(calculus, 'configurations'))
        configurations_cell = calculus.configurations;
    else
        add_info_log('configurations not found');
        return
    end
    
    %% Saved
    switch properties.save_type
        case 'csv'
            VariableNames{1} = 'config';
            i = 0;
            configurations{1} = [1:512]';
            for id = ids
                configurations_ = zeros(512, 1);
                if has_item(calculus, 'configurations', id, false)
                    configurations_(1:length(configurations_cell{id{:}})) ...
                        = configurations_cell{id{:}};
                else
                    continue;
                end
                i = i + 1;
                VariableNames{i + 1} = alg_name(id, true);
                configurations{i + 1} = configurations_;
            end
            T = table(configurations{:}, 'VariableNames', VariableNames);
            writetable(T, sprintf('%s.csv', file_name), ...
                'delimiter', ';');
        case 'mat'
            VariableNames{1} = 'config';
            i = 0;
            configurations{1} = [1:512]';
            for id = ids
                configurations_ = zeros(512, 1);
                if has_item(calculus, 'configurations', id, false)
                    configurations_(1:length(configurations_cell{id{:}})) ...
                        = configurations_cell{id{:}};
                else
                    continue;
                end
                i = i + 1;
                VariableNames{i + 1} = alg_name(id, true);
                configurations{i + 1} = configurations_;
            end
            configurations_table = table(configurations{:}, 'VariableNames', VariableNames);
            save(sprintf('%s.mat', file_name), 'configurations_table');
        case {'png', 'eps'}
            curproperties = properties;
            curproperties.visible = 0;
            curproperties.id_algorithm = id{2};
            if length(id_algo) == 2
                properties.file_name = 'configurations (ITMM) and (Yu Wei)';
                file_name = fullfile(properties.path, properties.file_name);
                curproperties.id_algorithm = id_algo;
            end
            fig = plot_configurations(calculus, curproperties);
            save_fig(fig, file_name, [0, 0, 16, 9], properties.save_type, false);
            close(fig);
    end
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Plot percent luminescence frame saved.');
    end
end
