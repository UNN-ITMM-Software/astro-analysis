function projects = unload_project(projects, id_project, solution)
    fname = build_path(projects(id_project).path, solution);
    projects(id_project) = [];
    is_opened = 0;
    save(fname, 'is_opened', '-append');
end