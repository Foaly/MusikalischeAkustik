%% Aufgabe 1

%% a)

close all;

equalTemperamentScale = EqualTemperamentScale(65.4064);

pythagoreanScale = PythagoreanScale(65.4064);

%% Aufgabe 2

%% a)

[midi,info,ext,ms_per_quarter,ms_per_tick] = midird3('BWV_846.midi');
 