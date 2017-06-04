function [out] = sineSynth(in, fs)
    %allocate whole signal
    out = zeros(ceil(fs*max(in(:,2))),1);
    %synthesize
    for i = 1:size(in,1)
        %generate sine signal for each note
        sine = genSine(in(i,4)/127, in(i,3), fs, in(i,2) - in(i,1), 0);
        %add sine signal to whole signal
        startsample = ceil(fs*in(i,1));
        endsample = ceil(fs*in(i,2));
        for j = startsample:endsample
            out(j) = out(j) + sine(j-startsample+1);
        end
    end
    %normalize
    out = out ./ (max(abs(out))) .*0.95;    
end