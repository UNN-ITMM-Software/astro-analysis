function [out] = view_events(events_3d, events_info, ids, frames)
out = frames;

events_info_ids = events_info.ids(ids);

colors = randi([0 255], 1, numel(events_info_ids));

events = { };
for i = 1 : numel(events_info_ids)
    for j = 1 : numel(events_3d)
        if events_info_ids(i) == events_3d(1).ids(j)            
            events{i} = cell2mat(events_3d(1).points(j));
            break;
        end
    end    
end

for j = 1 : numel(events)
    x = int32(events{j}(:,2) + 1);
    y = int32(events{j}(:,1) + 1);
    t = int32(events{j}(:,3) + 1);
    out(sub2ind(size(out),x,y,t)) = colors(j);
end

end

