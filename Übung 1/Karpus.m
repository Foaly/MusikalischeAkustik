function [samples] = Karpus(fs, f0, lengthInSec)
    wavetable = Wavetable(fs, f0);
    wavetableLength = size(wavetable, 2);
    sampleCount = fs * lengthInSec;
    samples = zeros(1, sampleCount);
    
    
    for i = 0:(sampleCount - 1)
        n = mod(i, wavetableLength) + 1;
        samples(i + 1) = wavetable(n);
    end
end