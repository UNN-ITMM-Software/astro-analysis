function [limit] = min_max(data)
    k = length(size(data));
    mn = min(data, [], k);
    mx = max(data, [], k);
    for i = (k - 1):-1:1
        mn = min(mn, [], i);
        mx = max(mx, [], i);
    end
    limit = [mn, mx];
end
