function project = load_project(project_dir, project_name, solution)
    fpath = fullfile(project_dir, [project_name, '.mat']);
    path = build_path(fpath, solution);
    if exist(path, 'file') ~= 2
        project = [];
        add_info_log(sprintf('Project %s not found.', project_name));
        return;
    end
    add_info_log(sprintf('Loading project ''%s''...', project_name));
    load(path, 'project');
    is_opened = 1;
    save(path, 'is_opened', '-append');
    
    project = upgrade_project(project);
    
    project.load_time = datetime('now');
    project.project_dir = build_path(project_dir, solution);
    project.path = path;
    [project.size, project.memory_size, project.disk_size] = get_project_size(project);
    
    add_info_log('Project loaded.');
end