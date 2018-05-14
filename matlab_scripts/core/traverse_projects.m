function projects = traverse_projects(projects, properties)
    for i = 1:length(projects)
        project = projects(i);
        if isfield(properties, 'selected_projects') && properties.selected_projects
            if ~project.selected
                continue
            end
        end
        switch properties.project_action
            case 'calculuses'
                [project] = ...
                    traverse_calculuses(project, properties);
            case 'save'
                project = save_project(project, properties.solution);
        end
        projects(i) = project;
    end
end