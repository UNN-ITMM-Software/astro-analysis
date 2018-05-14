function y = xlogx(x)
    y = zeros(size(x));
    y(x > 0) = x(x > 0) .* log(x(x > 0));
end