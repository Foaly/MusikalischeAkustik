function [output] = createNotes(midi,scale)
    % !!! first miditrack hardcoded !!!
    midi = midi{1,1};   
    output = [ midi(:,2) midi(:,2)+midi(:,4) scale([midi(:,3)]) midi(:,5) ]
end