%% Aufgabe 1
%% a)

close all

fs = 44100;
f0 = 100;

wavetable = Wavetable(fs, f0);

% b)

y1 = Karpus(fs, f0, 3.0);
audiowrite('y_1.wav', y1, fs);

y2 = Karpus(fs, f0, 3.0);
audiowrite('y_2.wav', y2, fs);

y3 = Karpus(fs, f0, 3.0);
audiowrite('y_3.wav', y3, fs);