function algo_name = alg_name(id, flag)
    if id{2} == 1
        name_algo = 'ITMM';
    else
        name_algo = 'Yu_Wei';
    end
    if flag
        algo_name = [name_algo, '_', int2str(id{1})];
    else
        algo_name = name_algo;
    end
end