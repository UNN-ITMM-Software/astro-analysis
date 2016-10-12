function [output] = norm_data(input, val)
mx = single(max(input(:)));
mn = single(min(input(:)));
output = uint8(val * (single(input) - mn) / (mx - mn));