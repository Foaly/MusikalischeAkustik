function [samples] = Karpus(fs, f0, lengthInSec)
    wavetable = Wavetable(fs, f0);
    wavetableLength = size(wavetable, 2);
    sampleCount = fs * lengthInSec;
    samples = zeros(1, sampleCount);
    
    for i = 1:sampleCount
        n = mod(i - 1, wavetableLength) + 1;
        samples(i) = wavetable(n);
    end
end