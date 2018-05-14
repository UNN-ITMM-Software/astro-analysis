function calculus = calc_noise_parameters(calculus, properties)
    add_info_log('Calculating noise parameters.');
    
    %% Load data
    data = calculus.(properties.input_video);
    noise = calculus.noise;
    
    %% Calculate
    add_info_log('Select region of video...');
    
    if size(data, 1) > size(noise, 1) || size(data, 2) > size(noise, 2)
        error(['Noise size [', num2str(size(noise, 1)), ', ', ...
            num2str(size(noise, 2)), '] less than size of input video [', ...
            num2str(size(data, 1)), ', ', num2str(size(data, 2)), '].', ...
            'Please load correct data.']);
    end
    
    noise = noise(1:size(data, 1), 1:size(data, 2), :);
    
    bm3d_noise = video_bm3d(noise);
    
    add_info_log('Noise parameters...');
    offset = mean(single(noise), 3);
    offset_sigma = std(single(noise), 0, 3);
    %offset_low = prctile(bm3d_noise, 2.5, 3);
    %offset_high = prctile(bm3d_noise, 97.5, 3);
    
    %offset_low = norminv(0.025, offset, offset_sigma);
    %offset_high = norminv(0.975, offset, offset_sigma);
    
    %noise_mask = mean(data, 3) < offset_high;
    noise_mask = std(single(data), 0, 3) < 3 * offset_sigma;
    
    %% Store data
    add_info_log('Storing data...');
    
    calculus.bm3d_noise = bm3d_noise;
    calculus.offset = offset;
    %calculus.offset_low = offset_low;
    %calculus.offset_high = offset_high;
    calculus.offset_sigma = offset_sigma;
    calculus.noise_mask = noise_mask;
    calculus.noise = noise;
    
    %%
    add_info_log('Noise parameters calculated.');
end