function [calculus] = calc_bm3d_video(calculus, properties)
    video = calculus.(properties.input_video);
    calculus.bm3d_video = video_bm3d(video);
end
