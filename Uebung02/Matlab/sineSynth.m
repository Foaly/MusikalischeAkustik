function [out] = sineSynth(in, fs, attack, decay)
    % allocate
    out = zeros(ceil(fs*max(in(:,2))),1);
    % convert from ms in samples
    attack = ceil(fs * attack);
    decay = ceil(fs * decay);

    % synthesize
    for i = 1:size(in,1)
        % generate sine
        sine = genSine(in(i,4)/127, in(i,3), fs, in(i,2) - in(i,1), 0);

        % apply envelope
        env_attack = envelope_(attack, 0);
        env_decay = envelope_(decay, 1);
        for j = 1:env_attack
            sine(j) = sine(j) * env_attack(j);
        end
        for j = size(sine,1) - env_decay + 1:size(sine,1)
            sine(j,1) = sine(j,1) * env_decay(j - (size(sine,1) - env_decay),1);
        end

        % add enveloped sine signal to whole signal
        startsample = ceil(fs * in(i,1));
        endsample = ceil(fs * in(i,2));
        for j = startsample:endsample
            out(j) = out(j) + sine(j - startsample + 1);
        end
    end
    
    % normalize
    out = out ./ (max(abs(out))) .* 0.95;
end