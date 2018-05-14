function [solution] = create_solution(solution_dir, name)
    solution.projects_paths = {};
    solution.name = name;
    solution.dir = fullfile(solution_dir, name);
    if exist(solution.dir, 'dir') ~= 7
        mkdir(solution.dir);
    end
    load_info_log({});
    add_info_log('Creating solution.');
    file_name = fullfile(solution.dir, strcat(solution.name, '.mat'));
    if exist(file_name, 'file') ~= 2
        save(file_name, 'solution');
    else
        choice = questdlg ...
            (sprintf('Solution %s already exist.\nDo you want to replace it?', solution.name), ...
            'Confirm replace', ...
            'Yes', 'No', 'No');
        switch choice
            case 'Yes'
                save(file_name, 'solution');
            case 'No'
                solution = [];
        end
    end
    add_info_log('Solution created.');
end