function ascpitch = midi2note(midipitch)
%function ascpitch = midi2note(midipitch)
%
%  cast MIDI pitch to ascii-representation
% 

% 60 equals 'c5'

r = rem(midipitch,12);
q = floor(midipitch/12);

switch r
   
case 0,
   p='c';
case 1,
   p='c#';
case 2,
   p='d';
case 3,
   p='eb';
case 4,
   p='e';
case 5,
   p='f';
case 6,
   p='f#';
case 7,
   p='g';
case 8,
   p='g#';
case 9,
   p='a';
case 10,
   p='hb';
case 11,
   p='h';
end

ascpitch = sprintf('%s%d',p,q);
