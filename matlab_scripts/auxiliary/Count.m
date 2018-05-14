function cnt = Count(array, len, type)
    persistent b
    b = zeros(1, len, type);
    for i = 1:length(array)
        b(array(i)) = b(array(i)) + 1;
    end
    cnt = b;
end
