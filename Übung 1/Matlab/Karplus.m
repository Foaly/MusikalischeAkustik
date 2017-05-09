%
% Karplus-Strong Algorithm
%
% fs          : Samplerate
% f0          : Fundamental frequency
% lengthInSec : Length of the output signal in seconds
% averageN    : Number of elements that are averaged
% gain        : Gain

function [samples] = Karplus(fs, f0, lengthInSec, averageN, gain)
    % generate wavetable and initialize stuff
    wavetable = Wavetable(fs, f0);
    wavetableLength = size(wavetable, 2);
    sampleCount = fs * lengthInSec;
    samples = zeros(1, sampleCount);
    
    for i = 0:(sampleCount - 1)
        head = mod(i, wavetableLength) + 1;
        
        % calculate the rolling average
        mean = wavetable(head);
        for j = 1:(averageN - 1)
            tail = mod(i + j, wavetableLength) + 1;
            mean = mean + wavetable(tail);
        end
        mean = mean / averageN;
        % modify the wavetable
        wavetable(head) = mean * gain;
        
        % write output
        samples(i + 1) = wavetable(head);
    end
end
