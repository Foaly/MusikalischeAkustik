%
% Sinewave Algorithm
%
% a           : Amplitude [0 1]
% fs          : Samplerate
% f           : Fundamental frequency
% t           : Length of the output signal in seconds
% phi         : Phase offset

function [sine] = genSine(a, f, fs, t, phi)
    w = 2*pi*f/fs;
    n = 0:ceil(fs * t);
    sine = a * sin(w * n + phi);
    %sine = [sine 0 0];
    sine = sine';
end