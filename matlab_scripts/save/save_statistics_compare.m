function [] = save_statistics_compare(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving statistics compare...');
    end
    
    %% Properties
    id_distr = properties.id_distr;
    file_name = fullfile(properties.path, properties.file_name);
    save_type = properties.save_type;
    id_algo = properties.id_algorithm;
    
    %% Load data
    ids = get_ids(properties, calculus, id_algo);
    if isequal(save_type, 'png') || isequal(save_type, 'eps')
        fig = plot_statistics_compare(calculus, ...
            setfield(properties, 'visible', 0));
        save_fig(fig, file_name, [0, 0, 10, 7], properties.save_type, false);
        close(fig);
    else
        count = 0;
        VariableNames{1} = 'threshold';
        VariableNames{2} = 'mean';
        VariableNames{3} = 'var';
        VariableNames{4} = 'coefs1';
        VariableNames{5} = 'coefs2';
        VariableNames{6} = 'alpha';
        VariableNames{7} = 'alpha_min';
        VariableNames{8} = 'alpha_max';
        VariableNames{9} = 'R_2';
        VariableNames{10} = 'F_stat';
        for id = ids
            events_stat = calculus.events_stat(id{:});
            if id{2} == 1
                postfix = 'ITMM';
                if id{1} > 1, postfix = ['ITMM', int2str(id{1} - 1)];
                end
            else if id{2} == 2
                    postfix = 'YuWei';
                end
            end
            
            %% Saved
            
            if id_distr == 1
                durations = events_stat.durations;
                if length(durations) == 0
                    continue
                end
                count = count + 1;
                stat_table(count, 1) = {postfix};
                stat_table(count, 2) = {durations.mean};
                stat_table(count, 3) = {durations.var};
                stat_table(count, 4:5) = {durations.coefs(1), durations.coefs(2)};
                stat_table(count, 6) = {durations.alpha.value};
                stat_table(count, 7:8) = {durations.alpha.ints(1), durations.alpha.ints(2)};
                stat_table(count, 9) = {durations.stats.rs};
                stat_table(count, 10) = {durations.stats.fs};
            else
                max_projections = events_stat.max_projections;
                if length(max_projections) == 0
                    continue
                end
                count = count + 1;
                stat_table(count, 1) = {postfix};
                stat_table(count, 2) = {max_projections.mean};
                stat_table(count, 3) = {max_projections.var};
                stat_table(count, 4:5) = {max_projections.coefs(1), max_projections.coefs(2)};
                stat_table(count, 6) = {max_projections.alpha.value};
                stat_table(count, 7:8) = {max_projections.alpha.ints(1), max_projections.alpha.ints(2)};
                stat_table(count, 9) = {max_projections.stats.rs};
                stat_table(count, 10) = {max_projections.stats.fs};
            end
        end
        switch save_type
            case 'csv'
                T = array2table(stat_table);
                T.Properties.VariableNames = VariableNames;
                writetable(T, sprintf('%s.csv', file_name), ...
                    'delimiter', ';');
            case 'mat'
                if id_distr == 1
                    durations = stat_table;
                    save(sprintf('%s.mat', file_name), 'durations');
                else
                    max_projections = stat_table;
                    save(sprintf('%s.mat', file_name), 'max_projections');
                end
        end
        
    end
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Statistics compare saved.');
    end
end
