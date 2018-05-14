function [] = logscale(ax, clever_lim, base, alpha_step, axis_c)
    set (ax, sprintf ('%cScale', axis_c), 'log');
    
    lim = get (ax, sprintf ('%cLim', axis_c));
    
    if clever_lim(1)
        h = findall(ax, 'Type', 'line');
        x = get(h, sprintf ('%cData', axis_c));
        v = [];
        if iscell(x)
            for n=1:length(x)
                v = cat(2, v, x{n,:});
            end
        else
            v = x;
        end
        v = unique(v);
        if ~isempty(v), lim(1) = min(v(v > 0)); end
        %if length(v) > 1, lim(1) = v(2); 
        %elseif ~isempty(v), lim(1) = v(1); end;
    end
    
    if clever_lim(2) && lim(2) / base^(nextpow(lim(2), base) - 1) / base > 0.5
        lim(2) = base^nextpow(lim(2), base);
    end
    set (ax, sprintf ('%cLim', axis_c), lim);
    
    be = (nextpow(lim(1), base^alpha_step) - 1);
    en = nextpow(lim(2), base^alpha_step);
    num = int32(en - be + 1);
    pw = linspace(be, en, num);
    tkvct = (base .^ alpha_step) .^ pw;
    set(ax, sprintf ('%cTick', axis_c), tkvct);
    
    tick_labels = {};
    for p=pw
        tick_labels{end + 1} = sprintf ('$%g^{%g}$', base, p*alpha_step);
    end
    set(ax, sprintf ('%cTickLabel', axis_c), tick_labels);
end