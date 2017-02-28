function [handle] = implay_map(frames, fps, window_name)

handle = implay(frames, fps);
colorbar;
handle.Visual.ColorMap.UserRangeMin = min(frames(:));
handle.Visual.ColorMap.UserRangeMax = max(frames(:));
handle.Visual.ColorMap.UserRange = 1;
handle.Visual.ColorMap.MapExpression = 'jet(256)';
set(handle.Parent, 'Name', window_name);
