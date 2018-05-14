function [fig] = plot_correlation_coefficients_double(calculus, properties, id)
    variable = properties.variable;
    variable_name = properties.variable_name;
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Painting ', variable_name{1}, ' vs ', variable_name{2}, ' ...']);
    end
    variable_info_cell = calculus.variable_info;
    variable_info(1:2) = [variable_info_cell.(variable_name{1}), ...
        variable_info_cell.(variable_name{2})];
    variable_info(1)
    curproperties = properties;
    curproperties.x_unit = {variable_info(1).x_unit};
    curproperties.y_unit = {variable_info(1).y_unit};
    curproperties.new_units = try_eval(variable_info(1).new_units);
    rescale_info_1 = rescale_variable(calculus, curproperties);
    curproperties.x_unit = {variable_info(2).x_unit};
    curproperties.y_unit = {variable_info(2).y_unit};
    curproperties.new_units = try_eval(variable_info(2).new_units);
    rescale_info_2 = rescale_variable(calculus, curproperties);
    ticks = calculus.ticks;
    ticks.time = ticks.time * rescale_info_1.new_coef(1);
    nt = length(ticks.time);
    frames_range = properties.frames_range;
    time = [max(1, frames_range(1)), min(frames_range(2), nt)];
    
    %% Painting
    number_fig = id;
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, number_fig, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, number_fig);
    end
    
    if id == 1
        color1 = [1, 0, 0];
        color2 = [0.5, 0, 0];
    elseif id == 2
        color1 = [1, 0.7, 0];
        color2 = [0.5, 0.3, 0];
    end
    clf(fig);
    ax = axes(fig);
    yyaxis(ax, 'left');
    plot(ax, ticks.time(time(1):time(2)), ...
        rescale_info_1.new_coef(2) * variable(time(1):time(2), 1), ...
        'DisplayName', variable_info(1).y_label, 'LineWidth', 3, 'Color', color1);
    ylabel(ax, [variable_info(1).y_label, ' ', rescale_info_1.new_units{2}])
    
    yyaxis(ax, 'right');
    plot(ax, ticks.time(time(1):time(2)), ...
        rescale_info_2.new_coef(2) * variable(time(1):time(2), 2), ...
        'DisplayName', variable_info(2).y_label, 'LineWidth', 3, 'Color', color2);
    ylabel(ax, [variable_info(2).y_label, ' ', rescale_info_2.new_units{2}])
    xlim(ax, [ticks.time(time(1)), ticks.time(time(2))]);
    xlabel(ax, [variable_info(1).x_label, ' ', rescale_info_1.new_units{1}]);
    
    corr = properties.corr;
    Str = ['Correlation coefficient = ', num2str(corr)];
    title(ax, Str);
    legend(ax, '-dynamicLegend');
    pretty_fig(fig);
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Number of events and number of regions painted.');
    end
end