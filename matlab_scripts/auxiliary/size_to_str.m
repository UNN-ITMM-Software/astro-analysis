function str_size = size_to_str(cur_size)
    str_size = sprintf('%dx', cur_size);
    str_size(end) = [];
end