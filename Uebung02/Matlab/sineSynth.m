function [out] = sineSynth(in, fs)
    out = zeros(0);
    
    for i = 1:size(in, 1)
        sine = genSine(in(i,4), in(i,3), fs, in(i,2) - in(i,1), 0);
    end
    
    % normalize
end