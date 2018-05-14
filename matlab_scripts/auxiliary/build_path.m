function path = build_path(path, solution, project)
    if nargin > 1
        path = strrep(path, '%solution_dir%', solution.dir);
    end
end