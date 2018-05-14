function calculus = calc_real_std(calculus, properties)
    add_info_log('Calculating noise parameters.');
    
    %% Load data
    noise_video = calculus.(properties.input_noise_video);
    filtered_video = calculus.(properties.input_filtered_video);
    noise = calculus.noise;
    bm3d_noise = calculus.bm3d_noise;
    offset = calculus.offset;
    
    %% Calculate
    
    S = std(noise_video - single(filtered_video), 0, 3);
    S_bm3d = std(bm3d_noise - repmat(offset, 1, 1, size(bm3d_noise, 3)), 0, 3);
    S_source = std(single(noise) - repmat(offset, 1, 1, size(bm3d_noise, 3)), 0, 3);
    S_ratio = S_source ./ S_bm3d;
    S_real = S ./ mean(S_ratio(:));
    S_real_smooth = imgaussfilt(S_real, 3);
    
    %% Store data
    add_info_log('Storing data...');
    calculus.f_noise_sigma = S_real_smooth;
    
    %%
    add_info_log('Noise parameters calculated.');
end
