function pianoroll(midi,col,mstart,mend)
% function pianoroll(midi,col,mstart,mend)    show piano roll representation of midi tracks
%
%  This function plots a simple piano roll representation of the given cell array
%  (or matrix in the case of one midi track) of midi tracks. Midi tracks may
%  be generated from standard MIDI files by the function midird.
%
%  Example: pianoroll(midi);               % plots all of the midi notes
%           pianoroll(midi{2});            % plots only the midi notes
%                                          % contained in midi track 2 ()
%           pianoroll(midi{3},1,100,200);  % plots the 100th - 200th midi
%                                          % notes in midi track 3 in color
%                                          % 1 (provided these notes exist!)
%

THICKNESS = 3;
XDIM = 1024;

if iscell(midi)
   midi = mergetracks(midi);
end

[lx,ly] = size(midi);
if nargin < 4
   mend = lx;
end

if nargin < 3
   mstart = 1;
end

%if nargin < 5
   
UNIT = XDIM/(midi(mend,2)-midi(mstart,2));
   
%end
   
if nargin < 2
   
   col=0;
   
end

proll = zeros(128*THICKNESS,XDIM);

for k = mstart:mend;
   
   if midi(k,5) ~= 0
      
      x1 = 1+midi(k,3)*THICKNESS;
      y1 = 1+ceil(UNIT*midi(k,2));
      x2 = midi(k,3)*THICKNESS+THICKNESS-col;
      y2 = 1+ceil(UNIT*(midi(k,2)+midi(k,4)));
      
      proll(1+midi(k,3)*THICKNESS:(midi(k,3)*THICKNESS+THICKNESS-col),...
         1+ceil(UNIT*midi(k,2)):1+ceil(UNIT*(midi(k,2)+midi(k,4)))) = (midi(k,6)+1+col) * 10;
      
      proll(x1:x2,y1:y1+2) = 100;
      proll(x1:x2,y2:y2+2) = 100;
      %proll(x1,y1:y2) = 100;
      %proll(x2,y1:y2) = 100;
      
   end
   
end

%image(proll(rev(1:128*THICKNESS),:));

image(proll);
axis xy;

miny = min(midi(:,3)-3)*THICKNESS;
maxy = max(midi(:,3)+3)*THICKNESS;
V = axis;
V(3)=miny;
V(4)=maxy;
axis(V);

colormap('lines');
c=colormap;
c(1,:)=[1 1 1];
colormap(c);

center=round(THICKNESS/3);

[yy,xx]=size(proll);

for k=10:100
   
	%line([1 xx],[k*THICKNESS+0.5 k*THICKNESS+0.5]);  
   text(0,1+k*THICKNESS+center,midi2note(k));
   
end

%v = axis;
%v = [v(1:2) 0 127];
%axis(v);


return;





if nargin < 3
   
   proll = zeros(128*THICKNESS,XDIM);
   
else
   
   [sy,sx]=size(proll);
   if (sy < 128*THICKNESS) | ( sx < XDIM )
      
      pold = proll;
      proll = zeros(128*THICKNESS,XDIM);
      proll(1:sy,1:sx)=pold;
      
   end
   
end
