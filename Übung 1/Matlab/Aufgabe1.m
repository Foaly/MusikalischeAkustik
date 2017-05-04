%% Aufgabe 1
%% a)

close all

fs = 44100;
f0 = 100;

wavetable = Wavetable(fs, f0);

% b)
gain = 1.0;

y1 = Karplus(fs, f0, 3.0, 1, gain);
audiowrite('y_1.wav', y1, fs);

y2 = Karplus(fs, f0, 3.0, 1, gain);
audiowrite('y_2.wav', y2, fs);

y3 = Karplus(fs, f0, 3.0, 1, gain);
audiowrite('y_3.wav', y3, fs);

%% c)
% TODO: Matlab lutscht. Rausfinden wie spectrogramme gehen
plot(abs(fft(y1)));


%% Aufgabe 2
gain = 0.9799;
y = Karplus(fs, f0, 3.0, 2, gain);
audiowrite('mean.wav', y, fs);
