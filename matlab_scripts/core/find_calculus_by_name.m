function [id] = find_calculus_by_name(calculus_info, name)
    id = find(strcmp({calculus_info.name}, name) == 1);
end
