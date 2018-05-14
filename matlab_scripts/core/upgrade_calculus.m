% Upgrade for store calculus on disk and partially loading data
function [project] = upgrade_calculus(project, solution)
    if isempty(project.calculus) || ...
            (isstruct(project.calculus) && isempty(fieldnames(project.calculus)))
        project.calculus = struct();
        empty = true;
    else
        empty = false;
    end
    project.calculus_path = fullfile(project.project_dir, ...
        ['calculus_', project.name], [project.name, '.calculus.mat']);
    project.calculus_path = build_path(project.calculus_path, solution);
    [calculus_dir, ~, ~] = fileparts(project.calculus_path);
    if exist(calculus_dir, 'dir') ~= 7
        mkdir(calculus_dir);
    end
    if ~empty && ~isa(project.calculus, 'CachedMatFiles')
        add_info_log('Calculus upgrading...');
        p = who(project.calculus);
        new_calculus = CachedMatFiles(project.calculus_path, 'Writable', true);
        for i = 1:length(p)
            new_calculus.(p{i}) = project.calculus.(p{i});
            add_info_log('Calculus upgrading...', double(i) / length(p));
        end
        add_info_log('Calculus upgraded.');
    end
    
    if exist(project.calculus_path, 'file') ~= 2
        calculus = struct();
        save(project.calculus_path, '-struct', 'calculus', '-v7.3');
        add_info_log(sprintf('Calculus %s not found. Created new file.', ...
            project.name));
    end
    project.calculus = CachedMatFiles(project.calculus_path, 'Writable', true);
end