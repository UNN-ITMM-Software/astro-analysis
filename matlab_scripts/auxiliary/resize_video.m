function resized_video = resize_video(video, coeff)
    A = imresize(logical(video(:, :, 1)), coeff);
    resized_video = zeros(size(A, 1), size(A, 2), size(video, 3));
    for i = 1:size(video, 3)
        resized_video(:, :, i) = imresize(logical(video(:, :, i)), coeff);
    end
end
