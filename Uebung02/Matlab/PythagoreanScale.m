function [scale] = PythagoreanScale(f0)
    % calculate the factors for the pythagoraen scale
    factors = zeros(12, 1);
    
    for n = 0:6
        i = power(1.5, n);
        
        while i > 2.0
            i = i / 2.0;
        end
        
        factors(n + 1) = i;
    end
    
    for n = 1:5
        i = power(1.5, -n);
        
        while i < 1.0
            i = i * 2.0;
        end
        
        factors(n + 7) = i;
    end
    
    factors = sort(factors);
    scale = factors;
    %scale = zeros(128, 1);
    
    %for n = 0:size(scale, 1)
    %    scale(n + 1) = f0 * factor(n)
    %end
end