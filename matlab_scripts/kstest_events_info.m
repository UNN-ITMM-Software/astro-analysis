function [kstest_duration, kstest_area] = kstest_events_info(events_info, ...
    ccdf_durations_a, ccdf_durations_b, ...
    ccdf_maxproj_a, ccdf_maxproj_b)

kstest_duration = kstest(double(events_info.durations), ...
    ccdf_durations_a, ccdf_durations_b);
kstest_area = kstest(double(events_info.max_projections), ...
    ccdf_maxproj_a, ccdf_maxproj_b);

end


function [lambda] = kstest(samples, a, b)

edges = unique(samples, 'sorted');
bins = histcounts(samples, edges, 'Nozmalization', 'probability');
for i = 1 : numel(bins) - 1
    bins(i + 1) = bins(i + 1) + bins(i);
end

fnx = 0;
fx = power_law(a, b, edges(1));
d_max = abs(fnx - fx);
for i = 2 : numel(edges)
    fnx = bins(i - 1);
    fx = power_law(a, b, edges(i));
    d = abs(fnx - fx);
    if d > d_max
        d_max = d;
    end    
end
lambda = d_max / numel(samples);

end


function [value] = power_law(a, b, x)

value = 1 - power(x, a) * power(exp(1), b);

end