function [wavetable] = Wavetable(fs, f0)
    length = ceil(fs/f0);
    wavetable = (rand(1, length) - 0.5) * 2;
end