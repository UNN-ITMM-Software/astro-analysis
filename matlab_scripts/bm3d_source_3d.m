function [] = bm3d_source_3d (file_name)

    [pathstr,name,ext] = fileparts(file_name);
    name = name(1:end-5);
    save_file = strcat(pathstr , '\', name, '_bm3d.mat');
    if exist(save_file, 'file') == 2
        return;
    end

    tic
    load(file_name);
    % save(strcat(pathstr, '\', name, '_data.mat'), 'data', '-v7.3');
    toc

    tic
    mx = max (data(:));
    mn = min (data(:));
    data_zmax = single(data - mn) / single(mx - mn);
    clear data
    % save(strcat(pathstr, '\', name, '_z-max.mat'), 'data_zmax', '-v7.3');
    toc

    tic
    data_bm3d = zeros(size(data_zmax), 'single');
    parfor i = 1:size(data_zmax, 3)
        [NA, data_bm3d(:,:,i)] = BM3D(1, data_zmax(:,:,i));
    end
    toc

    save(save_file, 'data_bm3d', '-v7.3');
end