function [] = view_all_distribution(events_info, events_stat, color)
    view_distribution(events_info, events_stat, color, 'durations', 'Duration (frames)');
    view_distribution(events_info, events_stat, color, 'max_projections', 'Max projection (pixels)');
end

function [] = view_distribution(events_info, events_stat, color, distribution, distr_label)
    % cd ('G:\astro')
    stat = events_stat.(distribution);
    n = events_info.numbers;
    a = stat.a;
    b = stat.b;
    r2 = stat.rs;
    s = sprintf('Algo: BackSub + Window. CCDF for %s.\n Number of events = %d, alpha = %f. R^2 = %f', distr_label, n, 1 - a, r2);
    fig = figure; % ('Visible','Off');
    AX = gca;
    % set(gcf, 'Position', [300 300 700 500]);
    
    % fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 4.7 3.8];
    fig.PaperPositionMode = 'manual';
    
    % set(fig,'FontSize',10)
    plot(AX, stat.ccdf(:,1), stat.ccdf(:,2), color, 'LineWidth', 2, 'DisplayName', distribution)
    hold on;
    plot(AX,stat.regr(:,1), stat.regr(:,2), sprintf('%s--', color), 'LineWidth', 2, 'DisplayName', sprintf('Regression for %s', distribution))
    set(AX,'yscale','log')
    set(AX,'xscale','log')
    set(AX,'xtickmode','auto')
    set(AX,'ytickmode','auto')
    
    axis([min(stat.ccdf(:,1)) max(stat.ccdf(:,1)) min(stat.ccdf(:,2)) max(stat.ccdf(:,2))])
    % axis([5 300 5e-3 1]) % duration
    % axis([40 200000 5e-3 1]) % max projection
    % axis([70 10000000 5e-3 1]) % volume
    
    
    xlabel(distr_label);
    ylabel('CCDF');
    
    title(s);
    legend(AX, '-DynamicLegend', 'Location','southwest');
    % print(fig, file_save,'-dpng','-r0');
end

