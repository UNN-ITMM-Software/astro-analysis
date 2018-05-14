function [calculus] = calc_registered_video(calculus, properties)
    add_info_log('Registering video.');
    
    %% Load data
    input_video = calculus.(properties.input_video);
    
    offset = zeros(size(input_video, 3), 2);
    registered_video = input_video;
    noise = calculus.noise;
    
    mean_value = 0;
    max_projection = max(input_video, [], 3);
    for k = 1:size(input_video, 3)
        add_info_log('Registering video', double(k) / size(input_video, 3));
        a = max_projection;
        b = input_video(:, :, k);
        
        corr_offset = [0, 0];
        c = normxcorr2(a, b);
        
        % offset found by correlation
        [~, imax] = max(abs(c(:)));
        [ypeak, xpeak] = ind2sub(size(c), imax(1));
        corr_offset = [(xpeak - size(a, 2)); ...
            (ypeak - size(a, 1))];
        
        % total offset
        offset(k, :) = corr_offset.';
        I = b;
        I = circshift(I, [offset(k, 1), offset(k, 2), 0]);
        
        mx = corr_offset;
        mn = corr_offset;
        
        li = 1 - mn(1);
        lj = 1 - mn(2);
        
        ri = size(input_video, 1) - mx(1);
        rj = size(input_video, 2) - mx(2);
        
        if k == 1
            I(1:li, 1:end) = mean_value;
            I(ri:end, 1:end) = mean_value;
            I(1:end, 1:lj) = mean_value;
            I(1:end, rj:end) = mean_value;
        else
            b = input_video(:, :, k - 1);
            I(1:li, 1:end) = b(1:li, 1:end);
            I(ri:end, 1:end) = b(ri:end, 1:end);
            I(1:end, 1:lj) = b(1:end, 1:lj);
            I(1:end, rj:end) = b(1:end, rj:end);
        end
        
        registered_video(:, :, k) = I;
    end
    
    mx_offset = max(abs(offset(:)));
    if mx_offset > 0
        add_info_log(sprintf('Image is moving by %dx%d. ', ...
            max(abs(offset(:, 1))), max(abs(offset(:, 2)))));
    else
        registered_video = input_video;
    end
    
    %% Store data
    calculus.(properties.output_video) = registered_video;
    
    %%
    add_info_log('Video registered.');
end