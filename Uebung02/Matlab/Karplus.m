%
% Karplus-Strong Algorithm
%
% fs          : Samplerate
% f0          : Fundamental frequency
% lengthInSec : Length of the output signal in seconds
% filter      : Filter coefficients
% gain        : Gain
% draw        : enable drawing

function [samples] = Karplus(fs, f0, lengthInSec, filter, gain, draw)
    % generate wavetable and initialize stuff
    wavetable = Wavetable(fs, f0);
    wavetableLength = size(wavetable, 2);
    sampleCount = ceil(fs * lengthInSec);
    samples = zeros(1, sampleCount);
    averageN = size(filter, 2);
    
    if draw == true
        figure;
    end

    for i = 0:(sampleCount - 1)
        head = mod(i, wavetableLength) + 1;
        
        % calculate the rolling average (only has an effect for 
        % averageN > 1)
        mean = wavetable(head);
        for j = 1:(averageN - 1)
            tail = mod(i + j, wavetableLength) + 1;
            mean = mean + wavetable(tail) * filter(j);
        end
        mean = mean / averageN;
        % modify the wavetable
        wavetable(head) = mean * gain;
        
        % write output
        samples(i + 1) = wavetable(head);
        
        % animation
        if draw == true && head == 1
            plot(wavetable);
            ylim([-1 1]);
            ylabel('Amplitude');
            xlim([0 wavetableLength]);
            xlabel('Samples');
            pause(0.1);
        end
    end
    
    samples = samples';
end
