function [] = save_events(calculus, properties)
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Saving events...');
    end
    
    %% Properties
    if ~isfield(properties, 'file_name') || strcmp(properties.file_name, '')
        properties.file_name = 'events';
    end
    if isfield(properties, 'id_threshold') && ~isempty(properties.id_threshold)
        properties.file_name = ...
            [properties.file_name, '_thr_', num2str(properties.id_threshold)];
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
            events_movie = view_events(calculus, properties);
            save_imgs2avi(events_movie, properties);
    end
    if ~isfield(properties, 'info_log') || properties.info_log
        add_info_log('Events saved.');
    end
end
