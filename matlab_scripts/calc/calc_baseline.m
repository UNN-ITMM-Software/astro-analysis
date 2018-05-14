function calculus = calc_baseline(calculus, properties)
    add_info_log('Calculating baseline video.');
    
    %% Load data
    video = calculus.(properties.input_video);
    noise_mask = calculus.noise_mask;
    f_noise_sigma = calculus.f_noise_sigma;
    field_value_struct = parse_config();
    if ~isfield(properties, 'df_f0_k_sigma')
        DF_F0_K_SIGMA = str2double(field_value_struct.DF_F0_K_SIGMA);
    else
        DF_F0_K_SIGMA = properties.df_f0_k_sigma;
    end
    MEAN_WINDOW_SIZE = int32(str2double(field_value_struct.MEAN_WINDOW_SIZE));
    
    %% Calculate
    video = permute(video, [3, 1, 2]);
    baseline = zeros(size(video), 'single');
    for i = 1:size(video, 2)
        for j = 1:size(video, 3)
            xx = video(:, j, i);
            xx = xx(:);
            base = xx;
            for k = 1:10
                base = movmean(min(xx, base), MEAN_WINDOW_SIZE);
                cur = max(0, base - xx);
                sd = sqrt(sum(cur.^2) ./ (length(cur) - 1));
                if sd < f_noise_sigma(i, j)
                    break;
                end
            end
            baseline(:, j, i) = base;
        end
    end
    video = permute(video, [2, 3, 1]);
    baseline = permute(baseline, [2, 3, 1]);
    
    dS_baseline = repmat(f_noise_sigma, 1, 1, size(baseline, 3)) ./ baseline;
    df_baseline_video = (video - baseline) ./ baseline;
    df_baseline_video(noise_mask) = 0;
    df_significant = df_baseline_video;
    df_significant(df_baseline_video < DF_F0_K_SIGMA * dS_baseline) = 0;
    
    %% Store data
    calculus.baseline_video = baseline;
    calculus.df_baseline_video = df_baseline_video;
    calculus.dS_baseline = dS_baseline;
    calculus.df_significant = df_significant;
    
    %%
    add_info_log('Baseline video calculated.');
end