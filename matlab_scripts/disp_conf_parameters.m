function [] = disp_conf_parameters(field_value_struct)

info_log(sprintf('----------------------------------------------------'));
info_log(sprintf('Configuration parameters:'));
info_log(sprintf('----------------------------------------------------'));
info_log(sprintf('BOOSTBINPATH = %s', field_value_struct.BOOSTBINPATH));
info_log(sprintf('MATLABBINPATH = %s', field_value_struct.MATLABBINPATH));
info_log(sprintf('OPENCVBINPATH = %s', field_value_struct.OPENCVBINPATH));
info_log(sprintf('MEXPATH = %s', field_value_struct.MEXPATH));
info_log(sprintf('BM3DPATH = %s', field_value_struct.BM3DPATH));
info_log(sprintf('THRESHOLDDFF = %s', field_value_struct.THRESHOLDDFF));
info_log(sprintf('WINDOWSIDE = %s', field_value_struct.WINDOWSIDE));
info_log(sprintf('MINPOINTS = %s', field_value_struct.MINPOINTS));
info_log(sprintf('EPS = %s', field_value_struct.EPS));
info_log(sprintf('THRESHOLDAREA = %s', field_value_struct.THRESHOLDAREA));
info_log(sprintf('THRESHOLDTIME = %s', field_value_struct.THRESHOLDTIME));
info_log(sprintf('MINAREA = %s', field_value_struct.MINAREA));
info_log(sprintf('MINDURATION = %s', field_value_struct.MINDURATION));
info_log(sprintf('----------------------------------------------------'));

end