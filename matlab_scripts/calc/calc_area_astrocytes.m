function [calculus] = calc_area_astrocytes(calculus, properties)
    add_info_log('Calculating area astrocytes...');
    
    %% Load data
    if ~isempty(whos(calculus, 'events_info'))
        max_projection_on_video = calculus.max_projection_on_video;
        events_info_cell = calculus.events_info;
        if ~isempty(events_info_cell(1, 1))
            events_info = events_info_cell(1, 1);
            
            %% Calculate
            area_astrocytes = zeros(events_info.height, events_info.width, 'single');
            lim = min_max(max_projection_on_video);
            max_projection_on_video = (max_projection_on_video - lim(1)) / (lim(2) - lim(1));
            level = graythresh(max_projection_on_video);
            area_astrocytes = double(max_projection_on_video > level);
            
            %% Store data
            calculus.area_astrocytes = area_astrocytes;
            
        end
    end
    
    %%
    add_info_log('Area astrocytes calculated.');
end
