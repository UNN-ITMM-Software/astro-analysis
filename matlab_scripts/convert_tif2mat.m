function [video] = convert_tif2mat(file_name)

video = [];
file_info = imfinfo(file_name);
for i = 1 : numel(file_info)
    image = imread(file_name, i, 'Info', file_info);
    [~, ~, num_channels] = size(image);
    if (num_channels > 1)
        image = rgb2gray(image);
    end
    disp(i);
    video = cat(3, video, image);
end

end