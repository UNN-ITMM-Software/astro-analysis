function [events_stat] = calc_statistics(events_info)
    events_stat.durations = calc_powerlaw(double(events_info.durations));
    events_stat.starts = calc_powerlaw(double(events_info.starts));
    events_stat.finishes = calc_powerlaw(double(events_info.finishes));
    events_stat.max_projections = calc_powerlaw(double(events_info.max_projections));
    % events_stat.volumes = calc_powerlaw(events_info.volumes);
end

function [y] = sqr(x)
    y = x * x;
end

function [a, b, alpha, rs, regr] = regression (ccdf)
    n = numel (ccdf(:, 1));
    ccdf_log = log (ccdf);
    sum_x = 0;
    sum_x2 = 0;
    sum_y = 0;
    sum_xy = 0;
    for i = 1:n
        sum_x = sum_x + ccdf_log(i, 1);
        sum_y = sum_y + ccdf_log(i, 2);
        sum_xy = sum_xy + ccdf_log(i, 1) * ccdf_log(i, 2);
        sum_x2 = sum_x2 + sqr(ccdf_log(i, 1));
    end
    a = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x);
    b = (sum_y - a * sum_x) / n;

    sst = 0; ssr = 0; ssx = 0;
    ys = sum_y / n; xs = sum_x / n;
    for i = 1:n
        ssx = ssx + sqr (ccdf_log(i, 1) - xs);
    end

    alpha = -a + 1;
    regr = ccdf;
    for i = 1:n
        regr(i,2) = exp (ccdf_log(i,1) * a + b);
    end
    for i = 1:n
        ssr = ssr + sqr (ccdf_log(i,1) * a + b - ccdf_log(i,2));
        sst = sst + sqr (ccdf_log(i,2) - ys);
    end

    % R-squared
    rs = 1.0 - ssr / sst;
end

function [ccdf] = calc_ccdf (data)
    n = numel (data);
    mn = min (data);
    % mx = max (data);
    tab = tabulate (data);
    cnt = tab(:,2);
    cnt(1) = n - cnt(1);
    ccdf = [];
    for i = 2:numel(cnt)
        cnt(i) = cnt(i - 1) - cnt(i);
        if cnt(i) == 0 
            break;
        end
        if cnt(i) == cnt(i - 1)
            continue;
        end
        if i >= mn 
            ccdf(end+1,:) = [i; cnt(i) / n];
        end
    end
end

function [stat] = calc_powerlaw (data)
    stat.mean = mean(data);
    stat.var = var(data);
    stat.ccdf = calc_ccdf (data);
    [stat.a, stat.b, stat.alpha, stat.rs, stat.regr] = regression (stat.ccdf);
end