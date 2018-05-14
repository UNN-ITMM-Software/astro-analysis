function [size, memory_size, disk_size] = get_project_size(project)
    s = whos('project');
    memory_size = s.bytes;
    if exist(project.path, 'file') == 2
        file_info = dir(project.path);
        disk_size = file_info.bytes;
    else
        disk_size = 0;
    end
    size = memory_size + disk_size; % not good
end