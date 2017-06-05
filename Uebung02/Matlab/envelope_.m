function [output] = envelope_(length, side)
output = zeros(length);
y = hann(2*length);
if side == 0;
    output = y(1:length);
end
if side == 1;
    output = y(length+1:end);
end
end