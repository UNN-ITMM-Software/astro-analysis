function [calculus] = calc_max_projection_on_video(calculus, properties)
    add_info_log('Calculating max projection on video...');
    
    %% Load data
    video = calculus.(properties.input_video);
    
    %% Calculate
    max_projection_on_video = max(video, [], 3);
    
    %% Store data
    calculus.max_projection_on_video = max_projection_on_video;
    
    %%
    add_info_log('Max projection on video calculated.');
end
