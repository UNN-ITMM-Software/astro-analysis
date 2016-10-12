function [data_2d_video, bm3d_video, preprocessed_video, df_f0_video, ...
    events_3d, events_info] = astrocyte_research(input_video, on_bm3d_filtering)

if (nargin < 2) || isempty(on_bm3d_filtering)
    on_bm3d_filtering = false;
end

field_value_struct = parse_config();
setenv('PATH', [getenv('PATH') ';' ...
                field_value_struct.BOOSTBINPATH ';' ...
                field_value_struct.MATLABBINPATH ';' ...
                field_value_struct.OPENCVBINPATH]);
            
% add path to all mex-files and BM3D implementation
addpath(field_value_struct.MEXPATH, field_value_struct.BM3DPATH);

% display configuration parameters
disp_conf_parameters(field_value_struct);

% convert algorithm parameters
thr_df_f0 = int32(str2num(field_value_struct.THRESHOLDDFF));
a = int32(str2num(field_value_struct.WINDOWSIDE));
min_points = int32(str2num(field_value_struct.MINPOINTS));
eps = int32(str2num(field_value_struct.EPS));
thr_area = str2double(field_value_struct.THRESHOLDAREA);
thr_time = str2double(field_value_struct.THRESHOLDTIME);
min_area = int32(str2num(field_value_struct.MINAREA));
min_duration = int32(str2num(field_value_struct.MINDURATION));

% check video dimension
info_log('Start: Check video dimension.');
data_2d_video = input_video;
if ndims(input_video) == 4 
    % find maximum projection
    info_log('Start: Compute maximum projection.');
    data_2d_video = reshape(max(data_2d_video, [], 3), ...
        [size(data_2d_video, 1) size(data_2d_video, 2) size(data_2d_video, 4)]);
    info_log('Finish: Compute maximum projection.');
end
info_log('Finish: Check video dimension.');

% call 'BM3D' method for filtering frames
if (on_bm3d_filtering)
    info_log('Start: BM3D filtering.');
    bm3d_video = video_bm3d(data_2d_video);
    info_log('Finish: BM3D filtering.');
else
    bm3d_video = data_2d_video; 
end

% call 'preprocessing' method for smoothing pixel's intensities by time
info_log('Start: Smoothing pixels intensities by time.');
preprocessed_video = preprocessing(bm3d_video);
info_log('Finish: Smoothing pixels intensities by time.');

% call 'background_subtraction' method to compute dF/F0
info_log('Start: Compute dF/dF0.');
% Parameters (optional):
%   thr_df_f0 - threshold of background subtraction method
df_f0_video = background_subtraction(preprocessed_video, ...
    struct('thr_df_f0', thr_df_f0));
info_log('Finish: Compute dF/dF0.');

% call 'find_events' method to construct events using 'sliding' window
info_log('Start: Construct events using sliding window.');
% Parameters (optional):
%   a            - side of the sliding window
%   min_points   - minimal number of points in one cluster
%   eps          - neighbourhood points in cluster
%   thr_area     - threshold of overlapping area in [0, 1]
%   thr_time     - threshold of overlapping time intervals in [0, 1]
%   min_area     - minimal event area
%   min_duration - minimal event duration
[events_3d, events_info] = find_events(df_f0_video, ...
    struct('a', a, ...
           'min_points', min_points, ...
           'eps', eps, ... 
           'thr_area', thr_area, ...
           'thr_time', thr_time, ...
           'min_area', min_area, ...
           'min_duration', min_duration));
info_log('Finish: Construct events using sliding window.');

end
