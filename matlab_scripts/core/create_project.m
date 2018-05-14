function [project] = create_project(project_name, astro_video_info, noise_video_info)
    add_info_log(sprintf('Creating project ''%s''...', project_name));
    
    project.name = project_name;
    project.version = 1;
    project.project_dir = '%solution_dir%';
    project.path = fullfile('%solution_dir%', ...
        sprintf('%s%s', project_name, '.mat'));
    project.astro_video_info = update_video_info(astro_video_info);
    project.noise_video_info = update_video_info(noise_video_info);
    project.selected = 0;
    
    project.calculus = struct();
    
    [project.calculus_info, ...
        project.calculus_config, ...
        project.columns_types] = load_calculus_config();
    [project.size, project.memory_size, project.disk_size] = get_project_size(project);
    project.save_time = datetime('now');
    project.load_time = datetime('now');
    add_info_log('Project created.');
end

function [video_info] = update_video_info(video_info)
    video_info.hash = get_hash(video_info.data_dir, video_info.data_files);
    [video_info.size, video_info.preview] = get_data_info ...
        (video_info.data_dir, video_info.data_files, ...
        video_info.data_type, video_info.var_name, ...
        video_info.channel_mask);
    video_info.type = video_info.data_type;
end

function [hash] = get_hash(dir_path, files_list)
    if ~iscell(files_list)
        files_list = {files_list};
    end
    hash_list = {};
    for i = 1:length(files_list)
        file = files_list{i};
        file_path = fullfile(dir_path, file);
        hash_list{end + 1} = DataHash(file_path, struct('Input', 'file'));
    end
    hash = DataHash(hash_list);
end