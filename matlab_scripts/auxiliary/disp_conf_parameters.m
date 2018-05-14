function [] = disp_conf_parameters(field_value_struct)
    
    add_info_log(sprintf('----------------------------------------------------'));
    add_info_log(sprintf('Configuration parameters:'));
    add_info_log(sprintf('----------------------------------------------------'));
    add_info_log(sprintf('BOOSTBINPATH = %s', field_value_struct.BOOSTBINPATH));
    add_info_log(sprintf('MATLABBINPATH = %s', field_value_struct.MATLABBINPATH));
    add_info_log(sprintf('OPENCVBINPATH = %s', field_value_struct.OPENCVBINPATH));
    add_info_log(sprintf('MEXPATH = %s', field_value_struct.MEXPATH));
    add_info_log(sprintf('BM3DPATH = %s', field_value_struct.BM3DPATH));
    add_info_log(sprintf('NORMLEFTBOUND = %s', field_value_struct.NORMLEFTBOUND));
    add_info_log(sprintf('NORMRIGHTBOUND = %s', field_value_struct.NORMRIGHTBOUND));
    add_info_log(sprintf('THRESHOLDDFF = %s', field_value_struct.THRESHOLDDFF));
    add_info_log(sprintf('WINDOWSIDE = %s', field_value_struct.WINDOWSIDE));
    add_info_log(sprintf('MINPOINTS = %s', field_value_struct.MINPOINTS));
    add_info_log(sprintf('EPS = %s', field_value_struct.EPS));
    add_info_log(sprintf('THRESHOLDAREA = %s', field_value_struct.THRESHOLDAREA));
    add_info_log(sprintf('THRESHOLDTIME = %s', field_value_struct.THRESHOLDTIME));
    add_info_log(sprintf('MINAREA = %s', field_value_struct.MINAREA));
    add_info_log(sprintf('MINDURATION = %s', field_value_struct.MINDURATION));
    add_info_log(sprintf('----------------------------------------------------'));
    
end