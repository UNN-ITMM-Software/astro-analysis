function [calculus_info, calculus_config, columns_types, last_modified_time] = load_calculus_config()
    
    %% Load from google docs
    url = 'https://docs.google.com/spreadsheets/d/1vY8jL-qoFknKMCynOQeJdIVDoY_UA8NNBAoeaemGtgc/export?format=tsv&id=1vY8jL-qoFknKMCynOQeJdIVDoY_UA8NNBAoeaemGtgc&gid=2115318687';
    file_name = which('columns_types.csv');
    urlwrite(url, file_name);
    
    url = 'https://docs.google.com/spreadsheets/d/1vY8jL-qoFknKMCynOQeJdIVDoY_UA8NNBAoeaemGtgc/export?format=tsv&id=1vY8jL-qoFknKMCynOQeJdIVDoY_UA8NNBAoeaemGtgc&gid=0';
    file_name = which('calculus_config.csv');
    urlwrite(url, file_name);
    
    %%
    columns_types = readtable('columns_types.csv', 'Delimiter', '\t');
    calculus_config = readtable('calculus_config.csv', ...
        'Format', repmat('%s', 1, height(columns_types)), 'Delimiter', '\t');
    last_modified_time = NaT;
    for j = 1:size(calculus_config, 2)
        column_last_modified_time = datetime(columns_types.last_modified_time{j}, ...
            'InputFormat', 'MM-dd-yyyy HH:mm:ss Z', 'TimeZone', 'local');
        if isnat(last_modified_time)
            last_modified_time = column_last_modified_time;
        else
            last_modified_time = max(column_last_modified_time, last_modified_time);
        end
        column_type = columns_types.type{j};
        column_name = columns_types.name{j};
        ok = strcmp(calculus_config.Properties.VariableNames(j), column_name);
        assert(ok == 1, ...
            sprintf('Column distinct in types and config: %s vs. %s', ...
            calculus_config.Properties.VariableNames{j}, column_name));
        for i = 1:size(calculus_config, 1)
            val = calculus_config.(column_name){i};
            switch column_type
                case 'string'
                    new_val = val;
                case 'cell'
                    new_val = try_eval(val);
                    if ischar(new_val), new_val = {new_val};
                    end
                    assert(iscell(new_val), 'Cell can''t convert');
                case 'array'
                    new_val = try_eval(val);
                case 'boolean'
                    if isempty(val), new_val = false;
                    elseif ischar(val), new_val = boolean(str2double(val));
                    elseif isnumeric(val)
                        try
                            new_val = boolean(val);
                        catch
                            new_val = false;
                        end
                    else assert(false, 'Boolean can''t convert');
                    end
                case 'double'
                    new_val = str2double(val);
                case 'int32'
                    new_val = int32(str2double(val));
                case 'datetime'
                    new_val = datetime(val, 'InputFormat', 'MM-dd-yyyy HH:mm:ss Z', 'TimeZone', 'local');
                otherwise
                    assert(false, 'No such column type!');
            end
            calculus_config.(column_name){i} = new_val;
            if strcmp(column_name, 'last_modified_time')
                last_modified_time = max(new_val, last_modified_time);
            end
        end
    end
    
    calculus_info = table2struct(calculus_config);
    for i = 1:length(calculus_info)
        calculus_info(i).id = i;
        calculus_info(i).is_algo = zeros(1, 2, 'logical');
        calculus_info(i).is_algo(calculus_info(i).id_algorithm) = true;
        
        calculus_info(i).is_calculated = zeros(1, 2, 'logical');
        calculus_info(i).is_exported = zeros(1, 2, 'logical');
        calculus_info(i).is_showed = zeros(1, 2, 'logical');
        calculus_info(i).is_valid = zeros(1, 2, 'logical');
        calculus_info(i).is_selected = false;
        
        calculus_info(i).calculate_start_time = [NaT, NaT];
        calculus_info(i).calculate_finish_time = [NaT, NaT];
        calculus_info(i).export_start_time = [NaT, NaT];
        calculus_info(i).export_finish_time = [NaT, NaT];
        calculus_info(i).show_start_time = [NaT, NaT];
        calculus_info(i).show_finish_time = [NaT, NaT];
        
        calculus_info(i).calculating_progress = -1;
        
        calculus_info(i).dir_path = ...
            fullfile('%solution_dir%', calculus_info(i).name);
        calculus_info(i).uuid_figure = calculus_info(i).name;
        dependencies = [];
        dep_str = calculus_info(i).dependencies;
        for j = 1:length(dep_str)
            id = find_calculus_by_name(calculus_info, dep_str{j});
            if ~isempty(id)
                dependencies = [dependencies, id];
            end
        end
        calculus_info(i).dependencies = dependencies;
    end
end
