astro_lab_dir = fileparts(which('run_astro_lab'));

files = dir(astro_lab_dir);

tic
for id = 1:length(files)
    if files(id).isdir == 0, continue;
    end
    dir_name = fullfile(astro_lab_dir, files(id).name);
    MBeautify.formatFiles(dir_name, '*.m');
end
toc
