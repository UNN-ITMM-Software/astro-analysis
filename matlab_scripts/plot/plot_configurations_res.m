function [fig] = plot_configurations_res(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Painting configuration resize video...');
    end
    
    %% Properties
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, 0, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, 0);
    end
    if isfield(properties, 'variable')
        variable = properties.variable;
    else
        add_info_log('variable not found');
        return
    end
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    clf(fig);
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    ids = get_ids(events_info_cell, id_algo, false);
    if ~isempty(whos(calculus, 'configurations_res'))
        configurations_cell = calculus.configurations_res;
    else
        add_info_log('configurations_res not found');
        return
    end
    if ~isempty(whos(calculus, 'variable_info'))
        temp = calculus.variable_info;
    else
        add_info_log('variable_info not found');
        return
    end
    variable_info = temp.(variable);
    ax = axes(fig);
    all_h = [];
    for id = ids
        id_algos = id{2};
        if has_item(calculus, 'configurations_res', id, false)
            configurations = configurations_cell{id{:}};
        else
            continue
        end
        if isempty(configurations)
            continue;
        end
        
        %% Painting
        if id_algos == 1
            params.name = '(ITMM)';
            params.color = [1, 0, 0];
        elseif id_algos == 2
            params.name = '(Yu Wei)';
            params.color = [1, 0.7, 0];
        end
        
        if isempty(configurations) || max(configurations) < 1
            continue;
        end
        hold on;
        h = plot(2:length(configurations) - 1, configurations(2:length(configurations) - 1), 'LineWidth', 3, ...
            'Color', params.color);
        if id{1} == 1
            h.DisplayName = params.name;
            all_h = [all_h, h];
        end
    end
    
    hold off;
    if length(id_algo) == 2
        params.name = [variable_info.name, sprintf('%.3f', calculus.resize_coef), ' (ITMM) and (Yu Wei)'];
    end
    xlabel(variable_info.plot{1});
    ylabel(variable_info.units_name);
    xlim([1, length(configurations)]);
    legend(all_h);
    title(params.name);
    pretty_fig(fig);
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Configuration resize video painted.');
    end
end