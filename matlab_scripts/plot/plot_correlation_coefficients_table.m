function [fig] = plot_correlation_coefficients_table(calculus, properties, id)
    variable_all = properties.variable_all;
    variable_all_names = properties.variable_names;
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log(['Painting plot correlation coefficients table ...']);
    end
    
    %% Painting
    number_fig = id;
    if isfield(properties, 'visible') && properties.visible == 0
        fig = get_figure(properties.uuid_figure, number_fig, 'Visible', 'Off');
    else
        fig = get_figure(properties.uuid_figure, number_fig);
    end
    if id == 1
        % name1 = [variable_name_1 ' (ITMM)'];
        % name2 = [variable_name_2 ' (ITMM)'];
        color1 = [1, 0, 0];
    else if id == 2
            %  name1 = [variable_name_1 ' (Yu Wei)'];
            % name2 = [variable_name_2 ' (Yu Wei)'];
            color1 = [1, 0.7, 0];
            color2 = [0.5, 0.3, 0];
        end
    end
    clf(fig);
    len = length(variable_all);
    axs = {};
    pos = [0, 0, 1, 1];
    for i = 1:len
        for j = 1:len
            ax = subplot(len, len, (i - 1) * len + j, 'Color', 'r');
            axs{i, j} = ax;
            %ax.Color = [0,0,0]; [234, 234, 242] / 255.0;
            %hold on;
            if i ~= j
                scatter(ax, variable_all{j}, variable_all{i}, 20, ...
                    'filled', 'MarkerFaceAlpha', 1 / 8, 'MarkerFaceColor', color1);
                xlim(ax, [min(variable_all{j}), max(variable_all{j})]);
                ylim(ax, [min(variable_all{i}), max(variable_all{i})]);
                if j == 1
                    ylabel(ax, variable_all_names{i})
                else
                    ax.YTickLabel = [];
                end
                if i == len
                    xlabel(ax, variable_all_names{j})
                else
                    ax.XTickLabel = [];
                end
            else
                h = histogram(ax, double(variable_all{i}));
                h.EdgeColor = [213, 213, 232] / 255.0;
                if j == 1
                    ylabel(ax, variable_all_names{i})
                else
                    ax.YTickLabel = [];
                end
                if i == len
                    xlabel(ax, variable_all_names{j});
                else
                    ax.XTickLabel = [];
                end
                xlim(ax, [min(variable_all{i}), max(variable_all{i})])
                ylim(ax, [min(h.Values), max(h.Values)])
            end
            ax.LabelFontSizeMultiplier = 2.0;
            if j > 1 && i < len
                ax.Position = ax.OuterPosition;
                pos = ax.Position;
            end
        end
    end
    for i = 1:len
        for j = 1:len
            
            if j == 1 || i == len
                ax = axs{i, j};
                pos_cur = ax.Position;
                ax.Position = [pos_cur(1), pos_cur(2), pos(3), pos(4)];
            end
        end
    end
    
    %value = table(variable_all{:}, 'VariableNames', variable_all_names);
    %corrplot(value,'rows','complete');
    %fig = gcf;
    axis square
    %xlabel(ax, variable_name_1)
    %ylabel(ax, variable_name_2)
    %corr = properties.corr;
    %Str = ['Correlation coefficient = ', num2str(corr)];
    %title(ax, Str);
    %legend(ax, 'Frame');
    pretty_fig(fig, 0.25);
    
    %%
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Number of events and number of regions painted.');
    end
end