function z = moving(y, len)
    y = y(:);
    a = (len - 1) / 2;
    cs = cumsum(y);
    z = zeros(length(y), 1, 'single');
    z(1:(a + 1)) = cs(1:2:len) ./ (1:2:len).';
    mask = length(z):-2:(length(z) - len + 2);
    z(end:-1:(end -a + 1)) = (cs(end) - cs(mask - 1)) ./ (1:2:(len - 2)).';
    
    z((a + 2):(end -a)) = cs((len + 1):end) - cs(1:(end -len));
    z((a + 2):(end -a)) = z((a + 2):(end -a)) ./ len;
end