function [video] = convert_imgs2mat(dir_name, files_name, channel_mask)
    if nargin == 1
        channel_mask = [true, true, true];
    end
    video = [];
    for i = 1:numel(files_name)
        full_file_name = fullfile(dir_name, files_name{i});
        image = imread(full_file_name);
        image = image_channel_mask(image, channel_mask);
        video = cat(3, video, image);
        add_info_log('Convert imgs to mat', double(i) / numel(files_name));
    end
end
