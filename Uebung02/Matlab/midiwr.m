function midiwr(fname,midi,info,ext)
% function midiwr(fname,midi,info,ext)    write standard MIDI file
%
%  A standard MIDI file is created from the notes-data given in the 'midi'
%  cell array (tracks) and the extended data in 'ext'/'info' (controller, meta, general,
%  and system messages). 
%
%  For a brief description of the format of midi,info,ext, see function        midird3    
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%   Last changes by Frank Kurth, Feb., 26th, 2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VLQLEN = 4;    % Length of variable length quantities, currently == 4 
TUPLEN = 6;

% open output file

fid = fopen(fname,'w');

if fid < 0
   disp('midird: Error opening output MIDI file!');
   return;
end

% write MIDI file header

fwrite(fid,double('MThd'),'uint8');
fwrite(fid,Write32(6),'uint8');
fwrite(fid,Write16(info.format),'uint8');
fwrite(fid,Write16(info.ntrks),'uint8');

if info.division.main ~= inf
   fwrite(fid,Write16(info.division.main),'uint8');
else
   fwrite(fid,[info.division.up info.division.low],'uint8');
end

%
% write tracks
%

if iscell(midi)
   curtrack = midi{1};
else
   curtrack = midi;
end

%
% rough estimate of maximum required buffer size 
%

[lx,ly] = size(curtrack);
if iscell(midi)
   for k=2:(length(midi))
      [x,y] = size(midi{k});
      lx = lx + x;
   end
end
trackimage = zeros(1,lx*7);

%
% extract info from ext struct
%

exttrack = zeros(1,length(ext));
exttime = zeros(1,length(ext));

for k = 1:length(ext)
   
   exttrack(k) = ext(k).track;
   exttime(k) = ext(k).abstime;
   
end

%[Y,I] = sort(exttime);

%
% track main loop
% 

for k = 1:info.ntrks
   
   abstime = 0;
   
   tracklen = 0;
   if(~isempty(curtrack))
      noteevents = GetNoteEvents(curtrack);
   else
      noteevents = [];
   end
   noteptr = 1;
   [lx,ly] = size(noteevents);
   if(~isempty(curtrack))
      noteevents(lx+1,:) = ones(1,ly)*inf;
   else
      noteevents = ones(1,TUPLEN)*inf;
   end
   
   curextidx = find(exttrack==k);
   curexttime = [exttime(curextidx) inf];
   extptr = 1;
   
   % merge notes and extended info to track image
   
   curexttime(length(curextidx)) = curexttime(length(curextidx)) + 1;
   
   while (extptr <= length(curextidx)) | (noteptr<=lx)
          
     if( curexttime(extptr) <= noteevents(noteptr,2) )   
        
         if extptr == length(curextidx)
            
            curexttime(length(curextidx)) = curexttime(length(curextidx)) - 1;
            
         end
         
         % write delta time
         
         newlen = length(ext(curextidx(extptr)).midistring);
         delta = curexttime(extptr)-abstime;
         abstime = curexttime(extptr);
         delta = WriteVarLenIntern(delta);
         trackimage(tracklen+1:tracklen+length(delta)) = delta;
         tracklen = tracklen + length(delta);
         
         % write extended info (per default this preceedes notes at the 
         % same time instant)
         
         trackimage(tracklen+1:tracklen+newlen) = ext(curextidx(extptr)).midistring;
         tracklen = tracklen + newlen;
         extptr = extptr + 1;
         
     else
         
         % write delta time
         
         delta = noteevents(noteptr,2)-abstime;
         abstime = noteevents(noteptr,2);
         delta = WriteVarLenIntern(delta);
         trackimage(tracklen+1:tracklen+length(delta)) = delta;
         tracklen = tracklen + length(delta);
         
         % compose note on/off command
         
         status = 128 + 16*noteevents(noteptr,1) + noteevents(noteptr,6);
                                                    % note on/off and channel
         trackimage(tracklen+1:tracklen+3) = [status noteevents(noteptr,3)...
                    noteevents(noteptr,5)];
         tracklen = tracklen + 3;
              
         noteptr = noteptr + 1;
      end
           
   end
   
   %
   % write to disk
   %
   
   fwrite(fid,double('MTrk'),'uint8');   
   fwrite(fid,Write32(tracklen),'uint8');
   fwrite(fid,trackimage(1:tracklen),'uint8');
   
   %
   % get next track
   %
   
   if k~=info.ntrks
      curtrack = midi{k+1};
   end
   
end
   
% close output file

fclose(fid);

%
% End of main function
%

%
% Write variable length quantity
%

function val = WriteVarLenIntern(number)

val = bitand(number,127)+128;

while fix(number/128)
   
   number = fix(number/128);
   val = [bitand(number,127)+128 val];
   
end

val(length(val)) = val(length(val)) - 128;

%
% Write to disk Write32
%

function val = Write32(number)

val = zeros(1,4);

for k = 1:4
   val(5-k) = rem(number,256);
   number = number / 256;
end
   
return;

%
% Write to disk Write16
%

function val = Write16(number)

val = [fix(number/256) bitand(number,255)];

return;

%
% calculate note-on and note-off events from midi track structure
%

function eventlist = GetNoteEvents(midi)

%listptr = 1;
[lx,ly]=size(midi);
nonzeros = find(midi(:,5)~=0);          % only nonzero velocities;

onlist = midi(nonzeros,:);
offlist = midi(nonzeros,:);

offlist(:,1) = 0;                       % delta time not needed,
onlist(:,1) = 1;                        % we abuse this entry to store info
                                        % whether note on (==1) or off (==0)
offlist(:,2) = offlist(:,2) + offlist(:,4);    % add duration to ON == point of OFF command

offlist(:,2) = offlist(:,2) - 0.5;     % Note-off commands have to preceede Note-on commands
                                       % occuring at the same time  (add
                                       % -0.5 to all time stamps prior to sorting) (*)

eventlist = [offlist; onlist];

[y,idx] = sort(eventlist(:,2));        % should not be too time consuming: we may save here
                                       % by exploiting that onlist is sorted and offlist is
                                       % nearly sorted with high probability
                                       
eventlist = eventlist(idx,:);

offidx = find(eventlist(:,1)==0);      % reverse process of (*) after sorting
eventlist(offidx,2) = eventlist(offidx,2) + 0.5;  %   -----"-----

return;



