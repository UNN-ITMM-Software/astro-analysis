function [handle] = show_video(frames, properties)
    %show_video Calls the implay function and adjust the color map
    % Call it with 3 parameters:
    % ImplayWithMap(frames, fps, limits)
    % frames - 4D arrray of images
    % fps - frame rate
    % limits - an array of 2 elements, specifying the lower / upper
    % of the liearly mapped colormap
    % Returns a hadle to the player
    %
    % example:
    % h = show_video(MyFrames, 30, [10 50])
    if nargin < 2
        properties = [];
    end
    if ~isfield(properties, 'file_name')
        properties.file_name = 'video';
    end
    if ~isfield(properties, 'fps') || properties.fps < 10
        fps = 10;
    else
        fps = properties.fps;
    end
    if ~isfield(properties, 'frames_range')
        frames_range = [1, size(frames, 3)];
    else
        if (properties.frames_range(2) > size(frames, 3))
            frames_range(1) = 1;
            frames_range(2) = size(frames, 3);
        else
            frames_range = properties.frames_range;
        end
    end
    if ~isfield(properties, 'limits') || isempty(properties.limits)
        limits(1) = double(min(frames(:)));
        limits(2) = double(max(frames(:)));
    else
        limits = double(properties.limits);
    end
    if ~isfield(properties, 'cmap')
        cmap = jet(256);
    else
        cmap = properties.cmap;
    end
    frames_video = frames(:, :, frames_range(1):frames_range(2));
    handle = implay(frames_video, fps);
    handle.Visual.ColorMap.Map = cmap;
    handle.Visual.ColorMap.UserRangeMin = limits(1);
    handle.Visual.ColorMap.UserRangeMax = limits(2);
    handle.Visual.ColorMap.UserRange = 1;
    pos = handle.Parent.Position;
    pos(3) = size(frames_video, 2) + 10;
    pos(4) = size(frames_video, 1) + 30;
    handle.Parent.Position = pos;
    handle.Parent.Name = properties.file_name;
end
