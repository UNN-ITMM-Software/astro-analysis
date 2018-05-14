function [field_value_struct] = parse_config(config_file_name)
    
    if (nargin < 1) || isempty(config_file_name)
        config_file_name = 'config.txt';
    end
    
    str = fileread(config_file_name);
    field_value_regex = regexp(str, '(?<field>\w+)[ ]*=[ ]*(?<value>[^\n]+)', 'names');
    field_value_struct = struct();
    for k = 1:length(field_value_regex),
        field = field_value_regex(k).field;
        val = field_value_regex(k).value;
        tf = ismember(val, char([34, 39])); % remove " and ' from string
        val = strtrim(val(~tf)); % also remove spaces
        field_value_struct.(field) = val;
    end
    
end
