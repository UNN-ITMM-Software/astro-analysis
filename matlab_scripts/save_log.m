function [] = save_log(log_strings, file_name)

fid = fopen(file_name, 'w');
for i = 1 : numel(log_strings)
    fprintf(fid, '%s\n', char(log_strings(i)));
end
fclose(fid);

end