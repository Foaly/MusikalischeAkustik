function [] = chromagram (MIDItrack, channel)
    notes = MIDItrack{1,channel}(:,3);
    notes = mod(notes, 12);
    figure;
    h = histogram(notes);
    h.FaceColor = 'k';
    title('Chromagram');
    ylabel('Occurrences');
    xlim([-1 12]);
    xticks([0 1 2 3 4 5 6 7 8 9 10 11 12])
    xticklabels({'C','Des/Cis','D','Es/Dis','E','F','Ges/Fis', 'G', 'As/Gis', 'A', 'As/B', 'H'})
end