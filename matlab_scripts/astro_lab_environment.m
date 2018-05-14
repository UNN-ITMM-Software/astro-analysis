astro_lab_dir = fileparts(mfilename('fullpath'));

if ~isdeployed
    
    %% Path to scripts
    addpath(astro_lab_dir);
    addpath(fullfile(astro_lab_dir, '../3rdparty/progress_bar'));
    addpath(fullfile(astro_lab_dir, '../3rdparty/DataHash'));
    addpath(fullfile(astro_lab_dir, '../3rdparty/tabplot'));
    addpath(fullfile(astro_lab_dir, '../3rdparty/plot_mk'));
    addpath(fullfile(astro_lab_dir, 'core'));
    addpath(fullfile(astro_lab_dir, 'auxiliary'));
    addpath(fullfile(astro_lab_dir, 'calc'));
    addpath(fullfile(astro_lab_dir, 'plot'));
    addpath(fullfile(astro_lab_dir, 'save'));
    addpath(fullfile(astro_lab_dir, 'config'));
end

config = parse_config();

if ~isdeployed
    
    %% Path to mex files
    path(config.MEXPATH, path);
    
    %% Path to BM3D
    path(config.BM3DPATH, path);
end

%% Add PATH for find_events
setenv('PATH', [getenv('PATH'), ';', ...
    config.BOOSTBINPATH, ';', ...
    config.MATLABBINPATH, ';', ...
    config.OPENCVBINPATH]);