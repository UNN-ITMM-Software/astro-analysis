function [data_bm3d] = video_bm3d (data)    
    tic
    mx = max (data(:));
    mn = min (data(:));
    data = single(data - mn) / single(mx - mn);
    toc

    tic
    data_bm3d = zeros(size(data), 'single');
    parfor i = 1:size(data, 3)
        [~, data_bm3d(:,:,i)] = BM3D(1, data(:,:,i));
    end
    toc
end