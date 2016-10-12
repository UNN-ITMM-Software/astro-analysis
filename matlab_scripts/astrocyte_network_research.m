function [video, bm3d_video, preprocessed_video, df_f0_video] = ...
    astrocyte_network_research(video)

field_value_struct = parse_config();
setenv('PATH', [getenv('PATH') ';' ...
                field_value_struct.BOOSTBINPATH ';' ...
                field_value_struct.MATLABBINPATH ';' ...
                field_value_struct.OPENCVBINPATH]);
            
% add path to all mex-files and BM3D implementation
addpath(field_value_struct.MEXPATH, field_value_struct.BM3DPATH);

video_single = im2single(video);

% call 'BM3D' method for filtering frames
info_log('Start: BM3D filtering.');
bm3d_video = zeros(size(video_single), 'single');
parfor i = 1 : size(video_single, 3)
    [~, bm3d_video(:,:,i)] = BM3D(1, video_single(:,:,i));
end
info_log('Finish: BM3D filtering.');

% call 'preprocessing' method for smoothing pixel's intensities by time
info_log('Start: Smoothing pixels intensities by time.');
preprocessed_video = preprocessing(bm3d_video);
info_log('Finish: Smoothing pixels intensities by time.');

% call 'background_subtraction' method to compute dF/F0
info_log('Start: Compute dF/dF0.');
df_f0_video = background_subtraction(preprocessed_video);
info_log('Finish: Compute dF/dF0.');

end