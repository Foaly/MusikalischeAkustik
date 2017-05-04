%% Aufgabe 2

close all

fs = 44100;
f0 = 100;

% a)

gain = 0.99999;
a = Karpus2(fs, f0, 3.0, 2, gain);

% b)

y4 = Karpus2(fs, f0, 3.0, 2, gain);
audiowrite('y_4.wav', y4, fs);

y5 = Karpus2(fs, f0, 3.0, 2, gain);
audiowrite('y_5.wav', y5, fs);

y6 = Karpus2(fs, f0, 3.0, 2, gain);
audiowrite('y_6.wav', y6, fs);