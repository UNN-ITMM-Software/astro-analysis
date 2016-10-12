% figure;
% view_distribution('Events_info_ccdf.txt', 'BackSub + threshold', 'r')
% view_distribution('Events_3d_stacks_ccdf.txt', 'Yu-Wei & Pimashkin', 'b')
% view_distribution('all_10 5 5 0.500000 0.500000_ccdf.txt', 'BackSub + Window', 'g')

function [] = view_distribution(file_name, method, color)
    cd ('F:\PC\Document Files\UNN\Coursework\Data\2015.04.28\2013-05-22_fileNo03\')
    % cd ('G:\astro')
    data = load(file_name, '-ascii');
    
    n = size(data, 1);
    a = data(1,1);
    b = data(1,2);
    r2 = data(2,1);
    s = sprintf('Algorithm: %s.\nCCDF for duration with alpha = %f. R^2 = %f', method, 1 - a, r2);
    figure;
    AX = axes;
    
    plot(AX, data(3:n,1), data(3:n,2), color, 'LineWidth', 2, 'DisplayName', method)
    hold on;
    plot(AX, data(3:n,1),data(3:n,3), sprintf('%s--', color), 'LineWidth', 2, 'DisplayName', sprintf('Regression for %s', method))
    set(AX,'yscale','log')
    set(AX,'xscale','log')
    set(AX,'xtickmode','auto')
    set(AX,'ytickmode','auto')
    xlabel('Duration');
    ylabel('CCDF');
    
    title(s);
    legend(AX, '-DynamicLegend');
end

