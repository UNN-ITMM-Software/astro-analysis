function [events_info, events_3d] = make_events_structs()
    fields_events_info = cell(12, 1);
    fields_events_info{1, 1} = 'number';
    fields_events_info{2, 1} = 'ids';
    fields_events_info{3, 1} = 'starts';
    fields_events_info{4, 1} = 'finishes';
    fields_events_info{5, 1} = 'durations';
    fields_events_info{6, 1} = 'max_projections';
    fields_events_info{7, 1} = 'video_size';
    fields_events_info{8, 1} = 'height';
    fields_events_info{9, 1} = 'width';
    fields_events_info{10, 1} = 'nt';
    fields_events_info{11, 1} = 'colors';
    fields_events_info{12, 1} = 'cmap';
    
    events_info = cell2struct(cell(length(fields_events_info), 1), ...
        fields_events_info);
    
    fields_events_3d = cell(10, 1);
    fields_events_3d{1, 1} = 'ids';
    fields_events_3d{2, 1} = 'points';
    fields_events_3d{3, 1} = 'spoints';
    fields_events_3d{4, 1} = 'border';
    fields_events_3d{5, 1} = 'to';
    fields_events_3d{6, 1} = 'centroids';
    fields_events_3d{7, 1} = 'edges';
    fields_events_3d{8, 1} = 'components';
    fields_events_3d{9, 1} = 'components_ptr';
    fields_events_3d{10, 1} = 'area';
    
    events_3d = cell2struct(cell(length(fields_events_3d), 1), ...
        fields_events_3d);
end
