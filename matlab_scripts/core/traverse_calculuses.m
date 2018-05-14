function [project] = traverse_calculuses(project, properties)
    switch properties.calculus_action
        case 'calc'
            add_info_log(['*** Calculating project: ', project.name]);
        case 'save'
            add_info_log(['*** Export calculus from project: ', ...
                project.name]);
        case 'show'
            add_info_log(['*** Show calculus from project: ', ...
                project.name]);
    end
    for i = 1:length(project.calculus_info)
        calculus_info = project.calculus_info(i);
        if isfield(properties, 'selected_calculus') && ...
                properties.selected_calculus
            if ~calculus_info.is_selected
                continue
            end
        end
        project = process_calculus(project, i, properties);
    end
    
    switch properties.calculus_action
        case 'calc'
            add_info_log(['*** Calculating project: ', ...
                project.name, ' finished']);
        case 'save'
            add_info_log(['*** Exporting calculus from project: ', ...
                project.name, ' finished']);
        case 'show'
            add_info_log(['*** Show calculus from project: ', ...
                project.name, ' finished']);
    end
end

function project = traverse_dependencies(project, id, properties)
    for id_dep = project.calculus_info(id).dependencies
        need_calc = ~project.calculus_info(id_dep).is_valid | ...
            ~project.calculus_info(id_dep).is_calculated;
        if any(need_calc(properties.id_algorithm))
            id_calculus = find([project.calculus_info(:).id] == id_dep, 1);
            id_algorithm = get_id_algorithm(properties.id_algorithm, need_calc);
            project = process_calculus(project, id_calculus, ...
                setfield(properties, 'id_algorithm', id_algorithm));
        end
    end
end

function [project] = process_calculus(project, id_calculus, properties)
    calculus_info = project.calculus_info(id_calculus);
    
    cur_properties = properties;
    properties = calculus_info;
    field_names = fieldnames(cur_properties);
    for i = 1:length(field_names)
        switch field_names{i}
            case 'id_algorithm'
                properties.(field_names{i}) = intersect( ...
                    cur_properties.(field_names{i}), ...
                    properties.(field_names{i}));
            otherwise
                properties.(field_names{i}) = cur_properties.(field_names{i});
        end
    end
    properties.algorithm_name{1} = 'ITMM algo';
    properties.algorithm_name{2} = 'Yu Wei algo';
    need_calc = ~calculus_info.is_calculated;
    
    eval_line = '';
    switch cur_properties.calculus_action
        case 'calc'
            project = traverse_dependencies(project, id_calculus, ...
                cur_properties);
            eval_line = calculus_info.calc_eval;
            project.calculus_info(id_calculus).calculate_start_time = datetime;
        case 'save'
            if any(need_calc)
                next_properties = cur_properties;
                next_properties.calculus_action = 'calc';
                next_properties.id_algorithm = ...
                    get_id_algorithm(properties.id_algorithm, need_calc);
                project = process_calculus(project, id_calculus, next_properties);
            end
            eval_line = calculus_info.save_eval;
            properties.uuid_figure = ...
                [project.name, char(31), calculus_info.name, '_save'];
            
            properties.path = get_project_export_dir(project);
            if isfield(properties, 'id_algorithm') && ...
                    ~isempty(properties.id_algorithm)
                if properties.id_algorithm == 1
                    algo_name = strrep(properties.algorithm_name{1}, ' ', '_');
                elseif properties.id_algorithm == 2
                    algo_name = strrep(properties.algorithm_name{2}, ' ', '_');
                elseif isequal(properties.id_algorithm, [1, 2])
                    algo_name = 'Compare_algos';
                end
                properties.path = fullfile(properties.path, algo_name);
            end
            
            if isfield(properties, 'save_dir') && ...
                    ~isempty(properties.save_dir)
                properties.path = ...
                    fullfile(properties.path, properties.save_dir);
            end
            if exist(properties.path, 'dir') ~= 7
                mkdir(properties.path);
            end
            project.calculus_info(id_calculus).export_start_time = datetime;
        case 'show'
            if any(need_calc)
                next_properties = cur_properties;
                next_properties.calculus_action = 'calc';
                next_properties.id_algorithm = ...
                    get_id_algorithm(properties.id_algorithm, need_calc);
                project = process_calculus(project, id_calculus, ...
                    next_properties);
            end
            eval_line = calculus_info.show_eval;
            properties.uuid_figure = ...
                [project.name, char(31), calculus_info.name];
            project.calculus_info(id_calculus).show_start_time = datetime;
    end
    
    calculus = project.calculus;
    
    eval(eval_line); % here may be used all variables
    
    project.calculus = calculus;
    properties = cur_properties;
    
    switch properties.calculus_action
        case 'calc'
            project.calculus_info(id_calculus).calculate_finish_time = datetime;
            project.calculus_info(id_calculus).is_calculated(properties.id_algorithm) = true;
            project.calculus_info(id_calculus).is_valid(properties.id_algorithm) = true;
            project = invalidate_child(project, id_calculus, properties.id_algorithm);
        case 'save'
            project.calculus_info(id_calculus).export_finish_time = datetime;
            project.calculus_info(id_calculus).is_saved(properties.id_algorithm) = true;
        case 'show'
            project.calculus_info(id_calculus).show_finish_time = datetime;
            project.calculus_info(id_calculus).is_showed(properties.id_algorithm) = true;
    end
end

function project = invalidate_child(project, id, id_algorithm)
    was = zeros(1, length(project.calculus_info), 'logical');
    st = [id];
    l = 1;
    was(l) = true;
    while (l <= length(st))
        cur = st(l);
        l = l + 1;
        for i = 1:length(project.calculus_info)
            if ~was(i) && any(project.calculus_info(i).dependencies == cur)
                st(end + 1) = i;
                project.calculus_info(i).is_valid(id_algorithm) = false;
                was(i) = true;
            end
        end
    end
end

function id_algorithm = get_id_algorithm(id_algorithm, need_calc)
    id_algorithm = id_algorithm(need_calc(id_algorithm) > 0);
end
