function calculus = calc_events_thresholds(calculus, properties, project)
    add_info_log('Calculating events for different sigma coefs.');
    
    if isfield(properties, 'id_algo')
        need_calc = any(id_algo == 1);
    else
        need_calc = 1;
    end
    
    if need_calc
        cache(calculus, 'events_info');
        cache(calculus, 'events_3d');
        
        input_video = calculus.(properties.input_video);
        
        properties.input_video = 'df_signinficant_thr';
        calculus.(properties.input_video) = [];
        cache(calculus, properties.input_video);
        
        dS_baseline = calculus.dS_baseline;
        
        k_sigma = input_video ./ dS_baseline;
        
        mx = quantile(k_sigma(:), 0.99);
        thresholds = linspace(0, mx, properties.NUM_THR + 1);
        
        clear k_sigma;
        
        add_info_log( ...
            sprintf('%d sigma coefs from 0 to %0.1g', properties.NUM_THR, mx));
        %% Calculate
        for i = 1:length(thresholds)
            threshold = thresholds(i);
            input_video(input_video < dS_baseline * threshold) = 0;
            
            calculus.(properties.input_video) = input_video;
            properties.id_events = {i + 1, 1};
            logging_disable();
            calculus = calc_events(calculus, properties, project);
            logging_enable();
            add_info_log('Calculating events for different sigma coefs...', ...
                double(i) / length(thresholds))
        end
        
        %% Store calculus
        add_info_log('Store events...');
        uncache(calculus, properties.input_video);
        uncache(calculus, 'events_info');
        uncache(calculus, 'events_3d');
        calculus.thresholds = thresholds;
    end
    
    %%
    add_info_log('Events calculated for different sigma coefs.');
end
