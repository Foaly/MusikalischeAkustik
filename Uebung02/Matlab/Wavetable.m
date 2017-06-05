%function to generate wavetable

function [wavetable] = Wavetable(fs, f0)
    %Calculate length of wavetable with N=fs/f0
    length = ceil(fs/f0);
    %fill wavetable with random numbers between -1 and 1 
    wavetable = (rand(1, length) - 0.5) * 2;
end
