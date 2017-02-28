function [] = save_results2video(data_zmax, data_2d_video, bm3d_video, ...
    preprocessed_video, df_f0_video, events_3d, events_info, flag, path)

if strcmp(flag, 'splitted')
    if (nargin < 8) || isempty(path)
        path = '';
    end
    save_imgs2avi(im2uint8(data_zmax), fullfile(path, 'data_zmax.avi'));
    save_imgs2avi(im2uint8(data_2d_video), fullfile(path, 'data_2d_video.avi'));
    save_imgs2avi(im2uint8(bm3d_video), fullfile(path, 'bm3d_video.avi'));
    save_imgs2avi(preprocessed_video, fullfile(path, 'preprocessed_video.avi'));
    save_imgs2avi(df_f0_video, fullfile(path, 'df_f0_video.avi'));
    ids = 1 : numel(events_3d);
    events_movie = view_events(events_3d, events_info, ids, df_f0_video);
    save_imgs2avi(events_movie, fullfile(path, 'events_movie.avi'));
elseif strcmp(flag, 'merged')
    ids = 1 : numel(events_3d);
    events_movie = view_events(events_3d, events_info, ids, df_f0_video);  
    full_video = vertcat(...
        horzcat(im2uint8(data_zmax), im2uint8(preprocessed_video)), ...    
        horzcat(df_f0_video, events_movie) ...
        );
    if (nargin < 8) || isempty(path)
        path = 'full_video.avi';
    end
    save_imgs2avi(full_video, path);
end

end