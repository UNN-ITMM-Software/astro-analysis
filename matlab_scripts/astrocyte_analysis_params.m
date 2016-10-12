function [] = astrocyte_analysis_params(input_video, file_name, ...
    on_bm3d_filtering)

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


min_points = 3;
eps = 3;
thr_area = 0.5;
thr_time = 0.1;

fid = fopen(file_name, 'w');
fprintf(fid, strcat('thr_df_f0;a;min_points;eps;thr_area;thr_time;', ...
    'min_area;min_duration;', ...
    'durations.alpha;durations.ds;durations.a;durations.b;', ...
    'max_projections.alpha;max_projections.ds;max_projections.a;max_projections.b\n'));


for thr_df_f0 = 10 : 15
    for a = 4 : 6
        for min_area = 10 : 15
            for min_duration = 7 : 10
                % call 'background_subtraction' method to compute dF/F0
                info_log('Start: Compute dF/dF0.');
                % Parameters (optional):
                %   thr_df_f0 - threshold of background subtraction method
                df_f0_video = background_subtraction(preprocessed_video, ...
                    struct('thr_df_f0', int32(thr_df_f0)));
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
                [~, events_info] = find_events(df_f0_video, ...
                    struct('a', int32(a), ...
                           'min_points', int32(min_points), ...
                           'eps', int32(eps), ... 
                           'thr_area', double(thr_area), ...
                           'thr_time', double(thr_time), ...
                           'min_area', int32(min_area), ...
                           'min_duration', int32(min_duration)));
                info_log('Finish: Construct events using sliding window.');

                % call 'calc_statistics' function to compute power law characteristics
                info_log('Start: Calculate power law characteristics.');
                events_stat = calc_statistics(events_info);
                info_log('Finish: Calculate power law characteristics.');

                fprintf(fid, '%d;%d;%d;%d;%f;%f;%d;%d;%f;%f;%f;%f;%f;%f;%f;%f\n', ...
                    thr_df_f0, a, min_points, eps, thr_area, thr_time, ...
                    min_area, min_duration, ...
                    events_stat.durations.alpha, events_stat.durations.rs, ...
                    events_stat.durations.a, events_stat.durations.b, ...
                    events_stat.max_projections.alpha, events_stat.max_projections.rs, ...
                    events_stat.max_projections.a, events_stat.max_projections.b ...
                );
            end
        end
    end
end
fclose(fid);

end