function [video] = convert_imgs2mat(dir_name)

img_set = [dir(fullfile(dir_name, '*.bmp')); ...
           dir(fullfile(dir_name, '*.jpg')); ...
           dir(fullfile(dir_name, '*.png'))];
video = [];
for i = 1: numel(img_set)
    full_file_name = fullfile(dir_name, img_set(i).name);
    disp(full_file_name);
    image = imread(full_file_name);
    [~, ~, num_channels] = size(image);
    if (num_channels > 1)
        image = rgb2gray(image);
    end
    video = cat(3, video, image);
end

end
