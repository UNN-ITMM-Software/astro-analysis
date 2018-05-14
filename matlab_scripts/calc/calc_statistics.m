function [calculus] = calc_statistics(calculus, properties)
    add_info_log('Calculating events statistics...');
    id_algos = properties.id_algorithm;
    
    if isempty(whos(calculus, 'events_stat'))
        events_stat = struct();
    else
        events_stat = calculus.events_stat;
    end
    ids = get_ids(properties, calculus, id_algos);
    
    i = 1;
    for id = ids
        
        %% Load data
        events_info = calculus.events_info(id{:});
        
        %% Calculate
        add_info_log('Calculating statistics for duration...', double(i) / length(ids));
        events_stat(id{:}).durations = calc_powerlaw(double(events_info.durations));
        
        add_info_log('Calculating statistics for max projections...', double(i) / length(ids));
        events_stat(id{:}).max_projections = calc_powerlaw(double(events_info.max_projections));
        
        i = i + 1;
    end
    
    %% Store data
    calculus.events_stat = events_stat;
    
    %%
    add_info_log('Statistics calculated.');
end

function [coefs, coefs_ints, alpha, stats, regr] = regression(ccdf)
    ccdf_log = log(ccdf);
    X = [ones(size(ccdf_log, 1), 1), ccdf_log(:, 1)];
    y = ccdf_log(:, 2);
    
    warning('off', 'stats:regress:RankDefDesignMat');
    [coefs, coefs_ints, ~, ~, stats_] = regress(y, X);
    warning('on', 'stats:regress:RankDefDesignMat');
    
    alpha.value = -coefs(2) + 1;
    alpha.ints = -coefs_ints(2, :) + 1;
    
    regr = ccdf;
    regr(:, 2) = exp(ccdf_log(:, 1) * coefs(2) + coefs(1));
    
    stats.rs = stats_(1);
    stats.fs = stats_(2);
    stats.pv = stats_(3);
end

function [stat] = calc_powerlaw(data)
    stat.mean = mean(data);
    stat.var = var(data);
    if size(data, 1) == 0 || size(data, 2) == 0
        x = zeros(0, 1);
        f = zeros(0, 1);
    else
        [f, x] = ecdf(data);
        f = 1 - f;
        [~, ix] = unique(x);
        ix = sort(ix);
        f = f(ix);
        x = x(ix);
        cf = min(f(f > 0));
        f(f == 0) = cf;
    end
    stat.ccdf = [x(f > 0 & x > 0), f(f > 0 & x > 0)];
    
    [stat.coefs, stat.coefs_ints, stat.alpha, stat.stats, stat.regr] = regression(stat.ccdf);
end