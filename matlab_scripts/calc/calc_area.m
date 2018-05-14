function [calculus] = calc_area(calculus, properties)
    add_info_log('Calculating area of events per frame...');
    
    %% Properties
    if ~isfield(properties, 'id_algorithm')
        id_algo = 1;
    else
        id_algo = properties.id_algorithm;
    end
    
    %% Loading data
    if ~isempty(whos(calculus, 'events_info'))
        events_3d_cell = calculus.events_3d;
        events_info_cell = calculus.events_info;
        ids = get_ids(properties, calculus, id_algo);
        
        %% Calculating
        for id = ids
            events_info = events_info_cell(id{:});
            events_3d = events_3d_cell(id{:});
            points = events_3d.points;
            area = cell(events_info.number, 1);
            for j = 1:events_info.number
                t = ordinal(points{j}(:, 3));
                tab = tabulate(t);
                area{j} = [str2double(tab(:, 1)), cell2mat(tab(:, 2))];
            end
            events_3d.area = area;
            events_3d_cell = upd_struct(events_3d, events_3d_cell, id);
        end
        
        %% Store data
        calculus.events_3d = events_3d_cell;
    end
    
    %%
    add_info_log('Area of events per frame calculated.');
end
