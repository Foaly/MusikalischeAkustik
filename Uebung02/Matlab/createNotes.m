function [output, tracklength] = createNotes(midiIn, ms_per_tick, scale)
    output = zeros(0);
    % iterate through all tracks inside the cell
    for i = 1:size(midiIn,2)
        midi = midiIn{1,i};
        if size(midi,1) ~= 0
            output = [ output; midi(:,2)*ms_per_tick/1000 (midi(:,2)+midi(:,4))*ms_per_tick/1000 scale([midi(:,3)]) midi(:,5) ];
        end
    end
end 

