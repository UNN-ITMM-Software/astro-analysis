function [calculus] = load_video(calculus, video, properties)
    data_files = video.data_files;
    output_video = properties.output_video;
    
    add_info_log('Loading video data...');
    switch video.type
        case 'mat'
            if iscell(data_files)
                file_name = data_files{1};
            else
                file_name = data_files;
            end
            file_name = fullfile(video.data_dir, file_name);
            data_file = matfile(file_name);
            calculus.(output_video) = data_file.(video.var_name);
        case 'tif'
            if iscell(data_files)
                file_name = data_files{1};
            else
                file_name = data_files;
            end
            file_name = fullfile(video.data_dir, file_name);
            calculus.(output_video) = convert_tif2mat(file_name, video.channel_mask);
        case 'imlist'
            calculus.(output_video) = ...
                convert_imgs2mat(video.data_dir, data_files, video.channel_mask);
    end
    add_info_log('Video data loaded.');
end
