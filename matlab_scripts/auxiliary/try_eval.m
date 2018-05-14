function new_val = try_eval(val)
    try
        new_val = eval(val);
    catch
        new_val = val;
    end
end