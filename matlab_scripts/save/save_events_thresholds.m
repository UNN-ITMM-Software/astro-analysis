function [] = save_events_thresholds(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving events...');
    end
    
    %% Properties
    id_thresholds = [1, 10, 20, 30];
    if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
        properties.file_name = 'events';
    end
    file_name = fullfile(properties.path, properties.file_name);
    
    if ~isfield(properties, 'save_type')
        properties.save_type = 'mat';
    end
    
    %% Saved
    switch properties.save_type
        case 'mat'
            events_info = calculus.events_info;
            events_3d = calculus.events_3d;
            save(sprintf('%s.mat', file_name), 'events_info', 'events_3d');
        case {'png', 'eps'}
            
        case 'avi'
            for i = 1:length(id_thresholds)
                properties.id_threshold = id_thresholds(i);
                save_events(calculus, properties);
            end
    end
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Events saved.');
    end
end
