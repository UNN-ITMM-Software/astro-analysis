function [output] = norm_data(input, val, limits)
    if nargin < 3
        mn = single(min(input(:)));
        mx = single(max(input(:)));
    else
        mn = single(limits(1));
        mx = single(limits(2));
    end
    output = uint8(val * (single(input) - mn) / (mx - mn));
end
