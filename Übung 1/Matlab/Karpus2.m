function [samples] = Karpus2(fs, f0, lengthInSec, filterLength, gain)
    wavetable = Wavetable(fs, f0);
    wavetableLength = size(wavetable, 2);
    sampleCount = fs * lengthInSec;
    samples = zeros(1, sampleCount);
    acc = 1;

    for i = 1:sampleCount
        n = mod(i - 1, wavetableLength) + 1;

        if (filterLength > 1)
            % moving on mean
            for j = 1:filterLength - 1
                m = mod(n + j, wavetableLength) + 1;
                wavetable(n) = wavetable(n) + wavetable(m);
            end

            % normalize
            wavetable(n) = wavetable(n) / filterLength;
        end

        % apply gain
        wavetable(n) = wavetable(n) * acc;
        acc = acc * gain;

        samples(i) = wavetable(n);
    end
end