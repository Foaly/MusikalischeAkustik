%% Aufgabe 1

%% a)

close all;

equalTemperamentScale = EqualTemperamentScale(16.3516);

pythagoreanScale = PythagoreanScale(16.3516);

%% Aufgabe 2

%% a)

[MIDItrack1, MIDIinfo1] = midird3('BWV_846.mid');
[MIDItrack2, MIDIinfo2] = midird3('BWV_858.mid');


%% b)

MIDItrack1Matrix = createNotes(MIDItrack1,equalTemperamentScale);
