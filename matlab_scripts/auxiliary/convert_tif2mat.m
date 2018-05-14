function [video] = convert_tif2mat(file_name, mask)
    if nargin == 1
        mask = 1:3;
    end
    add_info_log('Convert tif to mat...');
    video = [];
    file_info = imfinfo(file_name);
    [~, ~, ext] = fileparts(file_name);
    is_lsm = strcmp(ext, '.lsm');
    for i = 1:numel(file_info)
        if is_lsm && rem(i, 2) == 0, continue, end;
        
        image = imread(file_name, i, 'Info', file_info);
        [~, ~, num_channels] = size(image);
        if (num_channels > 1)
            image = sum(image(:, :, mask), 3) / length(mask);
        end
        video = cat(3, video, image);
        add_info_log('Convert tif to mat', i / numel(file_info));
    end
end