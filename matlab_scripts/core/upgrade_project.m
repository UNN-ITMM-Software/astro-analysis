function [project, upgrade] = upgrade_project(project)
    [calculus_info, ...
        calculus_config, ...
        columns_types, ...
        last_modified_time] = load_calculus_config();
    
    upgrade = false;
    cnt = 0;
    for j = 1:length(project.calculus_info)
        ok = false;
        for i = 1:length(calculus_info)
            if isfield(project, 'calculus_list')
                name = project.calculus_list(j).name;
            else
                name = project.calculus_info(j).name;
            end
            if strcmp(name, calculus_info(i).name)
                if isfield(project, 'calculus_list')
                    calculus_info = update_calculus_info_2( ...
                        calculus_info, i, project.calculus_info(j));
                else
                    calculus_info = update_calculus_info_1( ...
                        calculus_info, i, project.calculus_info(j));
                end
                ok = true;
                cnt = cnt + 1;
            end
        end
        if ~ok
            %calculus_info(end + 1) = project.calculus_info(j);
            upgrade = true;
        end
    end
    upgrade = upgrade || (cnt ~= length(calculus_info));
    
    project.calculus_info = calculus_info;
    if isfield(project, 'calculus_list')
        project = rmfield(project, 'calculus_list');
    end
    if isfield(project, 'calculus_array')
        project = rmfield(project, 'calculus_array');
    end
    project.calculus_config = calculus_config;
    project.columns_types = columns_types;
    project.calculus = load_variable_info(project.calculus);
    variable_info = project.calculus.variable_info;
    if isnat(variable_info.last_modified_time) || isnat(last_modified_time)
        variable_info.last_modified_time = last_modified_time;
    else
        last_modified_time = max( ...
            variable_info.last_modified_time, ...
            last_modified_time);
    end
    if isfield(project, 'config_last_modified_time')
        if project.config_last_modified_time < last_modified_time;
            upgrade = true;
        end
    else
        upgrade = true;
    end
    project.config_last_modified_time = last_modified_time;
    
    if upgrade
        add_info_log(['Project upgraded to time version  ', ...
            datestr(last_modified_time)]);
    end
end

function calculus_info = update_calculus_info_1(calculus_info, id, cur_project_calculus_info)
    calculus_info(id).is_calculated = ...
        cur_project_calculus_info.is_calculated;
    calculus_info(id).is_exported = ...
        cur_project_calculus_info.is_exported;
    calculus_info(id).is_showed = ...
        cur_project_calculus_info.is_showed;
    calculus_info(id).is_valid = ...
        cur_project_calculus_info.is_valid;
    calculus_info(id).is_selected = ...
        cur_project_calculus_info.is_selected;
    calculus_info(id).calculating_progress = ...
        cur_project_calculus_info.calculating_progress;
    calculus_info(id).calculate_start_time = ...
        cur_project_calculus_info.calculate_start_time;
    calculus_info(id).calculate_finish_time = ...
        cur_project_calculus_info.calculate_finish_time;
    calculus_info(id).export_start_time = ...
        cur_project_calculus_info.export_start_time;
    calculus_info(id).export_finish_time = ...
        cur_project_calculus_info.export_finish_time;
    calculus_info(id).show_start_time = ...
        cur_project_calculus_info.show_start_time;
    calculus_info(id).show_finish_time = ...
        cur_project_calculus_info.show_finish_time;
end

function calculus_info = update_calculus_info_2(calculus_info, id, cur_project_calculus_info)
    calculus_info(id).is_calculated = ...
        repmat(cur_project_calculus_info.is_calculated, 1, 2);
    calculus_info(id).is_exported = ...
        repmat(cur_project_calculus_info.is_saved, 1, 2);
    calculus_info(id).is_showed = ...
        repmat(cur_project_calculus_info.is_showed, 1, 2);
    calculus_info(id).is_valid = ...
        repmat(cur_project_calculus_info.is_valid, 1, 2);
    calculus_info(id).is_selected = ...
        cur_project_calculus_info.is_selected;
    calculus_info(id).calculating_progress = ...
        cur_project_calculus_info.calculating_progress;
    
    calculus_info(id).calculate_start_time = ...
        get_time(cur_project_calculus_info.is_calculated);
    calculus_info(id).calculate_finish_time = ...
        get_time(cur_project_calculus_info.is_calculated);
    calculus_info(id).export_start_time = ...
        get_time(cur_project_calculus_info.is_saved);
    calculus_info(id).export_finish_time = ...
        get_time(cur_project_calculus_info.is_saved);
    calculus_info(id).show_start_time = ...
        get_time(cur_project_calculus_info.is_showed);
    calculus_info(id).show_finish_time = ...
        get_time(cur_project_calculus_info.is_showed);
end

function curtime = get_time(flags)
    if flags
        curtime = [datetime, datetime];
    else
        curtime = [NaT, NaT];
    end
end
