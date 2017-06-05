function [out] = synthesize(in, fs, attack, decay, overtones, type)
    % allocate
    out = zeros(ceil(fs*max(in(:,2))),1);
    % convert from ms to samples
    attack = ceil(fs * attack);
    decay = ceil(fs * decay);
    
    % Karplus parameters
    gain = 0.9799;
    filter = [1.0, 1.0]; % moving average filter

    % synthesize
    for i = 1:size(in,1)
        amp = in(i,4)/127;
        frq = in(i,3);
        duration = in(i,2) - in(i,1);

        % the first one is the fundamental frequency
        for o = 1:overtones

            % generate samples
            if (strcmp(type,'Karplus'))
                samples = amp / o * Karplus(fs, frq * o, duration, filter, gain, false);
            else
                samples = genSine(amp / o, frq * o, fs, duration, 0);
            end

            % apply envelope
            env_attack = envelope_(attack, 0);
            env_decay = envelope_(decay, 1);
            for j = 1:size(env_attack, 1)
                samples(j) = samples(j) * env_attack(j);
            end
            decayStartOffset = size(samples,1) - size(env_decay, 1);
            for j = decayStartOffset + 1:size(samples,1)
                samples(j,1) = samples(j,1) * env_decay(j - decayStartOffset,1);
            end

            % add enveloped sine signal to whole signal
            startsample = ceil(fs * in(i,1));
            endsample = ceil(fs * in(i,2));
            length = endsample - startsample;
            out(startsample+1:endsample) = out(startsample+1:endsample) + samples(1:length);
        end
    end

    % normalize
    out = out ./ (max(abs(out))) .* 0.95;
end