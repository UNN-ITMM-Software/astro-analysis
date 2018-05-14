function t1 = output(outputString, wh, t, t1)
    
    whb = zeros(length(wh), 1);
    for n = 1:length(wh);
        whb(n) = wh(n).bytes;
    end;
    whb = sum(whb) / 1024 / 1024;
    if exist('add_info_log', 'file') ~= 2
        fprintf('(%6.1fs / %7.3fs) %s, occupied memory: %4.2fMB\n', t, t - t1, outputString, whb);
    else
        add_info_log(['Yu-Wei algo: ', outputString]);
    end
    
    t1 = t;
end
