function [fig] = plot_correlation_coefficients(calculus, properties, id)
    variable = properties.variable;
    variable_name = properties.variable_name;
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Painting ', variable_name{1}, ' vs ', variable_name{2}, ' ...']);
    end
    variable_info_cell = calculus.variable_info;
    variable_info(1:2) = [variable_info_cell.(variable_name{1}), ...
        variable_info_cell.(variable_name{2})];
    curproperties = properties;
    curproperties.x_unit = {variable_info(1).x_unit};
    curproperties.y_unit = {variable_info(1).y_unit};
    curproperties.new_units = try_eval(variable_info(1).new_units);
    rescale_info_1 = rescale_variable(calculus, curproperties);
    curproperties.x_unit = {variable_info(2).x_unit};
    curproperties.y_unit = {variable_info(2).y_unit};
    curproperties.new_units = try_eval(variable_info(2).new_units);
    rescale_info_2 = rescale_variable(calculus, curproperties);
    
    %% Painting
    number_fig = id;
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, number_fig, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, number_fig);
    end
    
    if id == 1
        color1 = [1, 0, 0];
    elseif id == 2
        color1 = [1, 0.7, 0];
    end
    clf(fig);
    ax = axes(fig);
    scatter(ax, rescale_info_1.new_coef(2) * variable(:, 1), ...
        rescale_info_2.new_coef(2) * variable(:, 2), 60, ...
        'filled', 'MarkerFaceAlpha', 3 / 8, 'MarkerFaceColor', color1);
    axis square
    xlabel(ax, [variable_info(1).y_label, ' ', rescale_info_1.new_units{2}])
    ylabel(ax, [variable_info(2).y_label, ' ', rescale_info_2.new_units{2}])
    corr = properties.corr;
    Str = ['Correlation coefficient = ', num2str(corr)];
    title(ax, Str);
    legend(ax, 'Frame');
    pretty_fig(fig);
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Number of events and number of regions painted.');
    end
end