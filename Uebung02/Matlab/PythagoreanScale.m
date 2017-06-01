function [scale] = PythagoreanScale(f0)
    % calculate the factors for the pythagoraen scale
    factors = zeros(12, 1);
    
    for n = 0:11
        if n <=6
            i = power(1.5, n);
        
            while i > 2.0
                i = i / 2.0;
            end
        else
            i = power(1.5, -(n-6));
        
            while i < 1.0
                i = i * 2.0;
            end
        end  
        factors(n +1) = i;
    end
        
    factors = sort(factors);
    scale = factors;
    
    scale = zeros(128, 1);
    
    for n = 0:size(scale, 1)
        scale(n + 1) = f0 * factors(mod(n,12)+1)* power(2,floor(n/12));
    end
end