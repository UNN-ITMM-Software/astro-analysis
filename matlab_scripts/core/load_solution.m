% solution = load_solution('c:\data\sol_1', 'sol_1'); without extension
function solution = load_solution(solution_dir, solution_name)
    path = fullfile(solution_dir, sprintf('%s.mat', solution_name));
    if exist(path, 'file') ~= 2
        solution = [];
        return;
    end
    add_info_log(sprintf('Loading solution %s.', solution_name));
    load(path, 'solution');
    solution.load_time = datetime('now');
    info_log_data = {};
    if isfield(solution, 'info_log_data')
        info_log_data = solution.info_log_data;
    end
    solution.dir = solution_dir;
    
    load_info_log(info_log_data);
    add_info_log('Solution loaded.');
end