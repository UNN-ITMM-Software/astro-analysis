function [] = save_events_flow(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving events flow...');
    end
    
    %% Properties
    if ~isfield(properties, 'save_type')
        properties.save_type = 'mat';
    end
    if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
        properties.file_name = 'events';
    end
    
    switch properties.save_type
        case 'mat'
            if ~isfield(properties, 'file_name') || ...
                    strcmp(properties.file_name, '')
                properties.file_name = 'events';
            end
            file_name = fullfile(properties.path, properties.file_name);
            events_info = calculus.events_info;
            events_3d = calculus.events_3d;
            save(sprintf('%s.mat', file_name), ...
                'events_info', 'events_3d', '-v7.3');
        case {'png', 'eps'}
            
        case 'avi'
    end
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Events flow saved.');
    end
end
