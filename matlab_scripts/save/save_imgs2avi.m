function [] = save_imgs2avi(data, properties)
    if ~isfield(properties, 'save_type')
        properties.save_type = 'avi';
    end
    if ~strcmp(properties.save_type, 'avi')
        return;
    end
    if ~isfield(properties, 'fps') || properties.fps < 10
        fps = 10;
    else
        fps = properties.fps;
    end
    if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
        properties.file_name = 'beginning_of_events';
    end
    if ~isfield(properties, 'cmap') || isempty(properties.cmap)
        properties.cmap = jet(256);
    end
    file_name = fullfile(properties.path, properties.file_name);
    if ~isa(data, 'uint8')
        data = norm_data(data, 255);
    end
    if exist('VideoWriter', 'class') ~= 0
        avi_obj = VideoWriter(file_name, 'Indexed AVI');
        avi_obj.Colormap = properties.cmap;
        avi_obj.FrameRate = fps;
        open(avi_obj)
        for k = 1:size(data, 3)
            writeVideo(avi_obj, data(:, :, k));
        end
        close(avi_obj);
    elseif exist('avifile', 'builtin') ~= 0
        avi_obj = avifile(properties.file_name, ...
            'compression', 'None', ...
            'colormap', properties.cmap, ...
            'fps', fps);
        for k = 1:size(data, 3)
            avi_obj = addframe(avi_obj, data(:, :, k));
        end
        close(avi_obj);
    else
        
        %% Strange situation
    end
end
