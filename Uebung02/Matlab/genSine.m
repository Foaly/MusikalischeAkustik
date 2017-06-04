function [sine] = genSine(a, f, fs, t, phi)
    w = 2*pi*f/fs;
    n = 0:fs * t - 1;
    sine = a * sin(w * n + phi);
    sine = [sine 0 0];
    sine = sine';
end