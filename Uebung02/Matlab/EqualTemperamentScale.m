function [scale] = EqualTemperamentScale(f0)
    scale = zeros(128, 1);
    scale(1) = f0; 
    
    for n = 2:size(scale, 1)
        scale(n) = power(nthroot(2, 12), n - 1) * f0;
    end
end