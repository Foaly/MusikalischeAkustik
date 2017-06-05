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
chromagram(MIDItrack1, 1);
chromagram(MIDItrack2, 2);

%% Aufgabe 3

%% a)
t1eqSine = synthesize(t1eq, 44100,0, 0, 1, 'Sine');

%audiowrite('t1eqSine_3a.wav', t1eqSine, 44100);

%% b)
t1eqSine = synthesize(t1eq, 44100,0.05,0.05,1 , 'Sine');
%audiowrite('t1eqSine_3b.wav', t1eqSine, 44100);

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

%% Aufgabe 4

%% a)
t1eqSine = synthesize(t1eq, 44100,0.05,0.05,3, 'Sine');
%audiowrite('t1eqSine_4a.wav', t1eqSine, 44100);


