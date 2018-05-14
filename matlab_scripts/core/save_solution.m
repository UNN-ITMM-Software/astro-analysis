function save_solution(solution)
    add_info_log(sprintf('Saving solution %s.', solution.name));
    global info_log_data
    path = build_path(fullfile(solution.dir, [solution.name, '.mat']));
    solution.save_time = datetime('now');
    solution.info_log_data = info_log_data;
    save(path, 'solution', '-v7.3');
    add_info_log('Solution saved');
end