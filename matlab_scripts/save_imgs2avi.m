function [] = save_imgs2avi(data, file_name)

cmap = vertcat(jet(127), 0.3 + rand (128, 3) * 0.69, [1,1,1]);

avi_obj = avifile(file_name, 'compression', 'None', 'colormap', cmap, 'fps', 25);

for k = 1 : size(data, 3)
    avi_obj = addframe(avi_obj, data(:, :, k));
end
avi_obj = close(avi_obj);

end