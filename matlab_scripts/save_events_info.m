function [] = save_events_info(events_info, file_name)

fid = fopen(file_name, 'w');
fprintf(fid, 'begin;end;duration;max_projection\n');
for i = 1 : events_info.numbers
    fprintf(fid, '%d;%d;%d;%d\n', ...
        events_info.starts(i), events_info.finishes(i), ...
        events_info.durations(i), events_info.max_projections(i));
end
fclose(fid);

end