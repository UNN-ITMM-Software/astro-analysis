function calculus = calc_smoothed_video(calculus, properties)
    add_info_log('Calculating smoothed video by time and subtract offset.');
    
    %% Load data
    data = calculus.(properties.input_video);
    
    %% Calculate
    data = smooth3(data);
    
    %% Store data
    calculus.smoothed_video = data;
    
    %%
    add_info_log('Smoothed video by time calculated and offset subtracted.');
end