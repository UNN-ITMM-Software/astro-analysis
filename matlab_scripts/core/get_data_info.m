function [sz, preview] = get_data_info ...
        (data_dir, data_files, data_type, var_name, channel_mask)
    if nargin < 5 || isempty(channel_mask)
        channel_mask = [true, true, true];
    end
    switch data_type
        case 'mat'
            if isa(data_files, 'matlab.io.MatFile')
                data_file = data_files;
            else
                if iscell(data_files)
                    file_name = data_files{1};
                elseif ischar(data_files)
                    file_name = data_files;
                end
                data_file = matfile(fullfile(data_dir, file_name));
            end
            file_info = whos(data_file, var_name);
            sz = file_info.size;
            if length(sz) == 3
                preview = data_file.(var_name)(:, :, 1);
            elseif length(sz) == 4
                preview = data_file.(var_name)(:, :, 1, :);
                preview = reshape(preview, ...
                    [size(preview, 1), size(preview, 2), size(preview, 4)]);
                preview(:, :, ~channel_mask) = 0;
            else
                
                %% Strange situation
            end
        case 'tif'
            if iscell(data_files)
                file_name = data_files{1};
            else
                file_name = data_files;
            end
            file_name = fullfile(data_dir, file_name);
            file_info = imfinfo(file_name);
            sz = [file_info(1).Width, file_info(1).Height, length(file_info)];
            preview = imread(file_name, 1, 'Info', file_info);
            if size(preview, 3) == 3
                preview(:, :, ~channel_mask) = 0;
            end
        case 'imlist'
            if ~iscell(data_files)
                data_files = {data_files};
            end
            file_name = fullfile(data_dir, data_files{1});
            file_info = imfinfo(file_name);
            sz = [file_info.Width, file_info.Height, length(data_files)];
            preview = imread(file_name);
            if size(preview, 3) == 3
                preview(:, :, ~channel_mask) = 0;
            end
    end
end