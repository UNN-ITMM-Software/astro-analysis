function save_merge_videos(calculus, properties)
    
    %% Properties
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving merge video.');
    end
    if ~isfield(properties, 'save_type')
        properties.save_type = 'avi';
    end
    if ~strcmp(properties.save_type, 'avi')
        return;
    end
    
    if ~isfield(properties, 'fps') || isempty(properties.fps)
        fps = 5;
    else
        fps = properties.fps;
    end
    
    if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
        file_name = 'merge';
    else
        file_name = properties.file_name;
    end
    
    if ~isfield(properties, 'cmap') || isempty(properties.cmap)
        cmap = [jet(255); [1, 1, 1]];
    else
        cmap = properties.cmap;
    end
    
    if isfield(properties, 'path')
        file_name = fullfile(properties.path, properties.file_name);
    end
    
    %% Load Data
    events_info = calculus.events_info;
    
    nt = events_info.nt;
    frames_range = [max(1, properties.frames_range(1)), ...
        min(nt, properties.frames_range(2))];
    
    events_movie = view_events(calculus, properties);
    
    source_video = calculus.source_video;
    smoothed_video = calculus.registered_video;
    df_significant = max(0, calculus.df_significant);
    
    lim_source = min_max(source_video);
    lim_bm3d = min_max(smoothed_video);
    lim_df_sig = [0, 2];
    
    A = zeros(30, size(source_video, 2), 'uint8');
    top_text = [plot_text(A, 'Source'), plot_text(A, 'Smoothed video')];
    bottom_text = [plot_text(A, 'Significant dF/F0'), plot_text(A, 'Events')];
    
    avi_obj = VideoWriter(file_name, 'Indexed AVI');
    avi_obj.Colormap = cmap;
    avi_obj.FrameRate = fps;
    open(avi_obj);
    for t = frames_range(1):frames_range(2)
        if ~isfield(properties, 'info_log') || properties.info_log
            add_info_log('Saving merge video...', ...
                double(t - frames_range(1)) / double(frames_range(2) - ...
                frames_range(1)));
        end
        source_im = norm_data(source_video(:, :, t), 254, lim_source);
        bm3d_im = norm_data(smoothed_video(:, :, t), 254, lim_bm3d);
        df_f0_im = norm_data(df_significant(:, :, t), 254, lim_df_sig);
        full_im = vertcat( ...
            top_text, ...
            horzcat(source_im, bm3d_im), ...
            horzcat(df_f0_im, events_movie(:, :, t)), ...
            bottom_text ...
            );
        
        writeVideo(avi_obj, full_im);
    end
    close(avi_obj);
    add_info_log('Merge video saved.');
end

function [im_text] = plot_text(A, str)
    im_text = insertText(A, [size(A, 2) / 2, size(A, 1) / 2], ...
        str, ...
        'AnchorPoint', 'Center', ...
        'TextColor', 'white', ...
        'BoxColor', 'black', ...
        'Font', 'Verdana', ...
        'FontSize', 18);
    im_text = 255 * (imbinarize(rgb2gray(im_text)));
end
