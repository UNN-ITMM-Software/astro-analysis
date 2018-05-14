function [] = save_statistics(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving statistics...');
    end
    
    %% Properties
    id_distr = properties.id_distr;
    file_name = fullfile(properties.path, properties.file_name);
    save_type = properties.save_type;
    id_algo = properties.id_algorithm;
    
    %% Load data
    ids = get_ids(properties, calculus, id_algo);
    if isequal(save_type, 'png') || isequal(save_type, 'eps')
        fig = plot_statistics(calculus, ...
            setfield(properties, 'visible', 0));
        save_fig(fig, file_name, [0, 0, 10, 7], properties.save_type, false);
        close(fig);
    else
        for id = ids
            events_stat = calculus.events_stat(id{:});
            ccdf_and_regr = [];
            if id{2} == 1
                postfix = '_ITMM';
                if id{1} > 1, postfix = ['_ITMM_', int2str(id{1})];
                end
            else if id{2} == 2
                    postfix = '_YuWei';
                end
            end
            file_name = [fullfile(properties.path, properties.file_name), postfix];
            
            %% Saved
            switch save_type
                case 'csv'
                    if id_distr == 1
                        durations = events_stat.durations;
                        if length(durations) == 0
                            continue
                        end
                        X = durations.ccdf(:, 1);
                        x = X(1);
                        ccdf = durations.ccdf(:, 2);
                        CCDF = ccdf(1);
                        REGR = durations.regr(:, 2);
                        regr = REGR(1);
                        T = table(x, CCDF, regr);
                        writetable(T, sprintf('%s.csv', file_name), ...
                            'delimiter', ';');
                        ccdf_and_regr(:, 1) = X;
                        ccdf_and_regr(:, 2) = ccdf;
                        ccdf_and_regr(:, 3) = REGR;
                        dlmwrite(sprintf('%s.csv', file_name), ...
                            ccdf_and_regr(2:length(X), :), '-append', 'delimiter', ';');
                    else
                        max_projections = events_stat.max_projections;
                        if length(max_projections) == 0
                            continue
                        end
                        X = max_projections.ccdf(:, 1);
                        x = X(1);
                        ccdf = max_projections.ccdf(:, 2);
                        CCDF = ccdf(1);
                        REGR = max_projections.regr(:, 2);
                        regr = REGR(1);
                        T = table(x, CCDF, regr);
                        writetable(T, sprintf('%s.csv', file_name), ...
                            'delimiter', ';');
                        ccdf_and_regr(:, 1) = X;
                        ccdf_and_regr(:, 2) = ccdf;
                        ccdf_and_regr(:, 3) = REGR;
                        dlmwrite(sprintf('%s.csv', file_name), ...
                            ccdf_and_regr(2:length(X), :), '-append', 'delimiter', ';');
                    end
                case 'mat'
                    if id_distr == 1
                        durations = events_stat.durations;
                        save(sprintf('%s.mat', file_name), 'durations');
                    else
                        max_projections = events_stat.max_projections;
                        save(sprintf('%s.mat', file_name), 'max_projections');
                    end
            end
        end
    end
    
    %% log
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Statistics saved.');
    end
end
