function project = save_project(project, solution)
    add_info_log(sprintf('Saving project %s...', project.name));
    path = build_path(project.path, solution);
    project.save_time = datetime('now');
    save(path, 'project', '-v7.3');
    [project.size, project.memory_size, project.disk_size] = get_project_size(project);
    add_info_log('Project saved.');
end