function [events_info] = calc_colors(events_info)
    s = rng;
    rng('default');
    events_info.colors = 0.3 + rand(128, 3) * 0.69;
    events_info.cmap = [jet(127); events_info.colors; [1, 1, 1]];
    rng(s);
end
