function str = STREP(str, old, new)
    if iscell(str)
        for i = 1:length(str)
            if iscell(old)
                for j = 1:length(old)
                    str{i} = strrep(str{i}, old{j}, new);
                end
            else
                str{i} = strrep(str{i}, old, new);
            end
        end
    else
        if iscell(old)
            for j = 1:length(old)
                str = strrep(str, old{j}, new);
            end
        else
            str = strrep(str, old, new);
        end
    end
end
