function to = upd_struct(from, to, id)
    field_names = fieldnames(from);
    for i = 1:length(field_names)
        if nargin == 3
            if iscell(id)
                to(id{:}).(field_names{i}) = from.(field_names{i});
            else
                to(id).(field_names{i}) = from.(field_names{i});
            end
        elseif nargin == 2
            to.(field_names{i}) = from.(field_names{i});
        end
    end
end
