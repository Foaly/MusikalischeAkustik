%% Aufgabe 1

%% a)

close all

% Create a wavetable that will result in a white tone with f0 = 100 Hz when 
% using a sample rate of fs = 44100 Hz
fs = 44100;
f0 = 100;

wavetable = Wavetable(fs, f0);

%% b)

% Set gain factor to 1 for the first task 
gain = 1.0;

% Set filter coefficients to 1 for the first task 
filter = [1.0];

% Generate three wave files with fundamental frequencies of 100 Hz using
% the karplus-strong algorithm. Wavetables have the same lengths 
% but different sets of random numbers
y1 = Karplus(fs, f0, 3.0, filter, gain, false);
audiowrite('y_1.wav', y1, fs);

y2 = Karplus(fs, f0, 3.0, filter, gain, false);
audiowrite('y_2.wav', y2, fs);

y3 = Karplus(fs, f0, 3.0, filter, gain, false);
audiowrite('y_3.wav', y3, fs);

%% c)

% calculate spectra of the three wave files 
sp1 = abs(fft(y1));
sp2 = abs(fft(y2));
sp3 = abs(fft(y3));

% normalize the spectra to the overall maximum amplitude
max_ampl = max([sp1 sp2 sp3]);
sp1 = sp1./max_ampl;
sp2 = sp2./max_ampl;
sp3 = sp3./max_ampl;

% generate a vector with the frequencies for the f-axis of the spectra
f=(0:(length(sp1)-1))/length(sp1)*fs; 

% plot all three spectra in different figures
figure;
plot(f,sp1);
title('spectrum of y\_1.wav');
xlim([0 2000]);
ylim([0 1]);
xlabel('f in Hz')
ylabel('normalized amplitude');
figure;
plot(f,sp2);
title('spectrum of y\_2.wav');
xlim([0 2000]);
ylim([0 1]);
xlabel('f in Hz')
ylabel('normalized amplitude');
figure;
plot(f,sp3);
title('spectrum of y\_3.wav');
xlim([0 2000]);
ylim([0 1]);
xlabel('f in Hz')
ylabel('normalized amplitude');


%% Aufgabe 2

%% a)

gain = 0.9799;
filter = [1.0, 1.0];

y = Karplus(fs, f0, 3.0, filter, gain, true);
audiowrite('mean.wav', y, fs);

%% b)

y4 = Karplus(fs, f0, 3.0, filter, gain, false);
audiowrite('y_4.wav', y4, fs);

y5 = Karplus(fs, f0, 3.0, filter, gain, false);
audiowrite('y_5.wav', y5, fs);

y6 = Karplus(fs, f0, 3.0, filter, gain, false);
audiowrite('y_6.wav', y6, fs);
