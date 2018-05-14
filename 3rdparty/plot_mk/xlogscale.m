function [] = xlogscale(ax, clever_lim, base, alpha_step)
    if nargin < 1
        ax = gca();
    end
    if nargin < 2
        clever_lim = [1 1];
    end
    if nargin < 3
        base = 10;
    end
    if nargin < 4
        alpha_step = 1;
    end
    logscale (ax, clever_lim, base, alpha_step, 'x');
end