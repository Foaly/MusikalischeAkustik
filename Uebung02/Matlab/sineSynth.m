function [out] = sineSynth(in, fs, env_length)
    %allocate whole signal
    out = zeros(ceil(fs*max(in(:,2))),1);
    %allocate envelope
    env_len = ceil(fs * env_length);
    env_left = zeros(env_len,1);
    env_right = zeros(env_len,1);
    %synthesize
    for i = 1:size(in,1)
        %generate sine signal for each note
        sine = genSine(in(i,4)/127, in(i,3), fs, in(i,2) - in(i,1), 0);
        %add envelope
        env_left = envelope_(env_len, 0);
        env_right = envelope_(env_len, 1);
        for j = 1:env_len
            sine(j) = sine(j)*env_left(j);
        end
        for j = size(sine,1)-env_len+1:size(sine,1)
            sine(j,1) = sine(j,1)*env_right(j-(size(sine,1)-env_len),1);
        end
        %add enveloped sine signal to whole signal
        startsample = ceil(fs*in(i,1));
        endsample = ceil(fs*in(i,2));
        for j = startsample:endsample
            out(j) = out(j) + sine(j-startsample+1);
        end
    end
    %normalize
    out = out ./ (max(abs(out))) .*0.95;    
end