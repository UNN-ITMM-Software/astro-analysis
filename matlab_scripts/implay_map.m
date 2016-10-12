function [handle] = implay_map(frames, fps, limits, cmap, window_name)
%ImplayWithMap Calls the implay function and adjust the color map
% Call it with 3 parameters:
% ImplayWithMap(frames, fps, limits)
% frames - 4D arrray of images
% fps - frame rate
% limits - an array of 2 elements, specifying the lower / upper
% of the liearly mapped colormap
% Returns a hadle to the player
%
% example: 
% h = implay_map(MyFrames, 30, [10 50])

handle = implay(frames, fps);
handle.Visual.ColorMap.Map = cmap;
handle.Visual.ColorMap.UserRangeMin = limits(1);
handle.Visual.ColorMap.UserRangeMax = limits(2);
handle.Visual.ColorMap.UserRange = 1;
set(handle.Parent, 'Name', window_name)
