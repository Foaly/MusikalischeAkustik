%% Aufgabe 1

%% a)

close all;

equalTemperamentScale = EqualTemperamentScale(16.3516);

pythagoreanScale = PythagoreanScale(16.3516);

%% c)

figure;
diff = [0 -10 4 -6 8 -2 +11 +2 -8 +6 -4 +10 0];
bar(diff, 'k');
ylim([-12 12]);
xticks([1 2 3 4 5 6 7 8 9 10 11 12 13])
xticklabels({'C','Des/Cis','D','Es/Dis','E','F','Ges/Fis', 'G', 'As/Gis', 'A', 'As/B', 'H', 'C'})
ylabel('Unterschied in Cent');
grid on;


%% Aufgabe 2

%% a)

[MIDItrack1, MIDIinfo1, ext1, ms_per_quarter1, ms_per_tick1] = midird3('BWV_846.mid');
[MIDItrack2, MIDIinfo2, ext2,  ms_per_quarter2, ms_per_tick2] = midird3('BWV_858.mid');


%% b)
t1eq = createNotes(MIDItrack1,ms_per_tick1,equalTemperamentScale);
t1py = createNotes(MIDItrack1,ms_per_tick1,pythagoreanScale);

t2eq = createNotes(MIDItrack2,ms_per_tick2,equalTemperamentScale);
t2py = createNotes(MIDItrack2,ms_per_tick2,pythagoreanScale);

%% c)
chromagram(MIDItrack1, 1, 'Chromagramm BMV\_846');
chromagram(MIDItrack2, 2, 'Chromagramm BMV\_858');

%% Aufgabe 3

%% a)
<<<<<<< Updated upstream
%t1eqSine = synthesize(t1eq, 44100,0, 0, 1, 'Sine');

%audiowrite('t1eqSine_3a.wav', t1eqSine, 44100);

%% b)
%t1eqSine = synthesize(t1eq, 44100,0.05,0.05,1 , 'Sine');
%audiowrite('t1eqSine_3b.wav', t1eqSine, 44100);
=======
% siehe synthesize.m

%% b)
>>>>>>> Stashed changes

figure;
subplot(1,2,1);
plot(envelope_(ceil(44100*0.05), 0));
xlim([0 ceil(44100*0.05)]);
xlabel('samplenumber');
ylabel('value');
title('Attack');
subplot(1,2,2);
plot(envelope_(ceil(44100*0.05),1));
xlim([0 ceil(44100*0.05)]);
xlabel('samplenumber');
ylabel('value');
title('Decay');

%% c)
fs = 44100;

% No envelope
t1eqSine = synthesize(t1eq, fs, 0, 0, 1, 'Sine');
audiowrite('t1eqSine.wav', t1eqSine, fs);

t1pySine = synthesize(t1py, fs, 0, 0, 1, 'Sine');
audiowrite('t1pySine.wav', t1pySine, fs);

t2eqSine = synthesize(t2eq, fs, 0, 0, 1, 'Sine');
audiowrite('t2eqSine.wav', t2eqSine, fs);

t2pySine = synthesize(t2py, fs, 0, 0, 1, 'Sine');
audiowrite('t2pySine.wav', t2pySine, fs);


% With envelope
t1eqSineEnv = synthesize(t1eq, fs, 0.05, 0.05, 1, 'Sine');
audiowrite('t1eqSineEnv.wav', t1eqSineEnv, fs);

t1pySineEnv = synthesize(t1py, fs, 0.05, 0.05, 1, 'Sine');
audiowrite('t1pySineEnv.wav', t1pySineEnv, fs);

t2eqSineEnv = synthesize(t2eq, fs, 0.05, 0.05, 1, 'Sine');
audiowrite('t2eqSineEnv.wav', t2eqSineEnv, fs);

t2pySineEnv = synthesize(t2py, fs, 0.05, 0.05, 1, 'Sine');
audiowrite('t2pySineEnv.wav', t2pySineEnv, fs);

%% Aufgabe 4

%% a)
t1eqSineOver = synthesize(t1eq, fs, 0.05, 0.05, 19, 'Sine');
audiowrite('t1eqSineOver.wav', t1eqSineOver, fs);

t1pySineOver = synthesize(t1py, fs, 0.05, 0.05, 19, 'Sine');
audiowrite('t1pySineOver.wav', t1pySineOver, fs);

t2eqSineOver = synthesize(t2eq, fs, 0.05, 0.05, 19, 'Sine');
audiowrite('t2eqSineOver.wav', t2eqSineOver, fs);

t2pySineOver = synthesize(t2py, fs, 0.05, 0.05, 19, 'Sine');
audiowrite('t2pySineOver.wav', t2pySineOver, fs);

%% Zusatzaufgabe

t1eqKarplus = synthesize(t1eq, fs, 0, 0, 19, 'Karplus');
audiowrite('t1eqKarplus.wav', t1eqKarplus, fs);

t2eqKarplus = synthesize(t2eq, fs, 0, 0, 19, 'Karplus');
audiowrite('t2eqKarplus.wav', t2eqKarplus, fs);
