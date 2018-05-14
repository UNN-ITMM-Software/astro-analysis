function has_item = has_item(calculus, name_field, id, flag)
    bool = true;
    try
        if ~is_created(calculus, name_field)
            bool = false;
        else
            value = calculus.(name_field)(id{:});
            if flag
                bool = ~isempty(value);
            else
                bool = ~isempty(value{1});
            end
        end
    catch
        bool = false;
    end
    if ~bool
        if id{2} == 1
            str_algo = '(ITMM)';
        elseif id{2} == 2
            str_algo = '(Yu Wei)';
        elseif id{2} == 3
            str_algo = '(Yu Wei dF/F0 + sliding window)';
        end
        add_info_log(['Field ', name_field, ' not found for ', str_algo]);
    end
    
    has_item = bool;
end
