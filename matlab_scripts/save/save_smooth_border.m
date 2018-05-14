function [] = save_smooth_border(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving smooth border...');
    end
    
    %% Properties
    if ~isfield(properties, 'save_type')
        properties.save_type = 'mat';
    end
    
    %% saved
    switch properties.save_type
        case 'mat'
            if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
                properties.file_name = 'events';
            end
            file_name = fullfile(properties.path, properties.file_name);
            events_info = calculus.events_info;
            events_3d = calculus.events_3d;
            save(sprintf('%s.mat', file_name), ...
                'events_info', 'events_3d', '-v7.3');
        case {'png', 'eps'}
            
        case 'avi'
            if ~isfield(properties, 'file_name') || ...
                    strcmp(properties.file_name, '')
                properties.file_name = 'smooth_events';
            end
            file_name = fullfile(properties.path, properties.file_name);
            properties.type = 'spoints';
            events_movie = view_events(calculus, properties);
            save_imgs2avi(events_movie, properties);
            
            properties.file_name = 'smooth_border';
            file_name = fullfile(properties.path, properties.file_name);
            properties.type = 'border';
            events_movie = view_events(calculus, properties);
            save_imgs2avi(events_movie, properties);
    end
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Smooth border saved.');
    end
end
