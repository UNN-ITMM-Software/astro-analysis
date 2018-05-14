function [data_bm3d] = video_bm3d(data)
    add_info_log('BM3D filtering.');
    
    %% Calculation
    add_info_log('Data normalizing...');
    tic
    mx = prctile(data(:), 99.9);
    mn = min(data(:));
    data = single(data - mn) / single(mx - mn);
    toc
    
    add_info_log('VBM3D...');
    tic
    [~, data_bm3d] = VBM3D(data, 40, 0, 1);
    toc
    
    add_info_log('Data normalizing...');
    tic
    data_bm3d = single(data_bm3d) * single(mx - mn) + single(mn);
    toc
    
    %%
    add_info_log('BM3D filtered.');
end