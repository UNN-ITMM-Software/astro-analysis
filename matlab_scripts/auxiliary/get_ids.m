function ids = get_ids(properties, calculus, id_algos)
    get_ids_method = properties.get_ids_method;
    events_info = calculus.events_info;
    need_thresholds = false;
    if get_ids_method > 1
        need_thresholds = true;
        number_of_thresholds = true;
        if get_ids_method == 3 || get_ids_method == 5
            number_of_thresholds = 5;
        end
    end
    if need_thresholds
        sz = size(events_info, 1);
        if islogical(number_of_thresholds)
            number_of_thresholds = sz - 1;
        end
        if get_ids_method > 3
            thresholds_ids = unique(int32(linspace(2, sz, number_of_thresholds)));
        else
            thresholds_ids = [1, unique(int32(linspace(2, sz, number_of_thresholds)))];
        end
    else
        sz = 1;
        thresholds_ids = 1;
    end
    [X, Y] = meshgrid(thresholds_ids, id_algos);
    Z = [num2cell(X(:)), num2cell(Y(:))];
    all_ids = mat2cell(Z, ones(1, size(Z, 1)), size(Z, 2)).';
    ids = {};
    for id_ = all_ids
        id = id_{:};
        number = events_info(id{:}).number;
        if ~isempty(number) && number > 0
            ids{1, end + 1} = id{1};
            ids{2, end} = id{2};
            %ids{end + 1} = id;
        end
    end
end
