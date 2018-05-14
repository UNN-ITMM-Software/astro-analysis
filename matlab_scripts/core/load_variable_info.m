function calculus = load_variable_info(calculus)
    
    %% Load from google docs
    url = 'https://docs.google.com/spreadsheets/d/1Z1mRaC311NO9QYPnsDybeAETQb3KbP8cfm2gUZ6EY9A/export?format=tsv&id=1Z1mRaC311NO9QYPnsDybeAETQb3KbP8cfm2gUZ6EY9A&gid=0';
    file_name = which('variable_info.csv');
    urlwrite(url, file_name);
    
    %%
    variable_info = readtable('variable_info.csv', 'Delimiter', '\t');
    variable_info_struct = struct();
    last_modified_time = NaT;
    for i = 1:height(variable_info)
        name = variable_info{i, 'variable_name'}{1};
        row = table2struct(variable_info(i, :));
        variable_info_struct.(name) = row;
        variable_info_struct.(name).init_units = ...
            try_eval(variable_info_struct.(name).init_units);
        variable_info_struct.(name).units_power = ...
            [variable_info_struct.(name).L_exp, ...
            variable_info_struct.(name).T_exp, ...
            variable_info_struct.(name).I_exp];
        row_last_modified_time = datetime( ...
            variable_info{i, 'last_modified_time'}{1}, ...
            'InputFormat', 'MM-dd-yyyy HH:mm:ss Z', 'TimeZone', 'local');
        variable_info_struct.(name).last_modified_time = row_last_modified_time;
        if isnat(last_modified_time)
            last_modified_time = row_last_modified_time;
        else
            last_modified_time = max(row_last_modified_time, last_modified_time);
        end
    end
    variable_info_struct.last_modified_time = last_modified_time;
    calculus.variable_info = variable_info_struct;
end
