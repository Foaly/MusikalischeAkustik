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

[MIDItrack1, MIDIinfo1] = midird3('BWV_846.mid');
[MIDItrack2, MIDIinfo2] = midird3('BWV_858.mid');


%% b)

MIDItrack1Matrix = createNotes(MIDItrack1,equalTemperamentScale);
