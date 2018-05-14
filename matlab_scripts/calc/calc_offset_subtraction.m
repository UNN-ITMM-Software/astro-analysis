function calculus = calc_offset_subtraction(calculus, properties)
    add_info_log('Calculating subtract offset.');
    
    %% Load data
    data = calculus.(properties.input_video);
    
    %% Calculate
    data = single(data) - repmat(calculus.offset, 1, 1, size(data, 3));
    
    %% Store data
    calculus.offset_subtracted_video = data;
    
    %%
    add_info_log('Offset subtracted.');
end