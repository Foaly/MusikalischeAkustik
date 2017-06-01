function [skala] = EqualTemperamentScale(f0)
    skala = zeros(128);
    skala(1) = f0; 
    
    for n = 2:size(skala, 1)
        skala(n) = power(nthroot(2, 12), n - 1) * f0;
    end
end