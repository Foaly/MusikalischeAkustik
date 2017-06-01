function [midi,info,ext,ms_per_quarter,ms_per_tick] = midird3(fname,txtname)
% function [midi,info,ext,ms_per_quarter,ms_per_tick] = midird3(fname,txtname)
%
%  This function reads Standard MIDI Files (SMFs) and returns their contents
%  in the two structures midi and info.
%
%     midi     is a struct array containing one field for each track of the
%              midi file. Within each field, the midi notes are given in
%              the format
%
%              (delta time,absolute time, midi note number, note duration, note velocity,
%               channel)
%
%     info     contains all sideinfo from the header chunk as well as meter and time
%              information from the MIDI meta events
%
%     ext      is all extended information besides notes contained in the MIDI file.
%              This is needed, e.g., to reproduce the binary MIDI files
%              using midiwr.m
%              
%              -> All system exclusive data are stored in ext
%
%              Format of ext:  (track abstime [binary MIDI sequence])
%
%     ms_per_quarter     milliseconds per quarter note, if indicated by
%              MIDI-file (set to 0, if no information on time-coding is
%              found in MIDI-file)
%
%     ms_per_tick       milliseconds per MIDI tick, if indicated by
%              MIDI-file (set to 0, if no information on time-coding is
%              found in MIDI-file)
%
%  Inputs:    fname     Name of input MIDI-File
%
%			  (optional) txtname   Name of Output-Textfile
%
%             If the optional second argument txtname is used, a text
%             version of the MIDI-file is written to a file named textname
%
%   Changes:  * Frank Kurth, Feb., 26th, 2004: Rework to cope with wrongly
%             formatted SMFs
%             * Andreas Ribbrock, Apr., 14th, 2004: Stabilized w.r.t. wrongly
%             formatted SMFiles
%             * Frank Kurth, May, 11th, 2004: Incorporated functionality to
%             read time-coding from SMF (by Hinnerk Feldwisch and Meinard Müller)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%   Last changes by Frank Kurth, May, 11th, 2004
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
VLQLEN = 4;    % Length of variable length quantities, currently == 4 
TUPLEN = 6;

% The following are define global for use in the subfunctions within
% this file:

global smf;
global abstime;
%global ext;
%global extptr;

% some constants

UNDEF = -1; NOTEON = 0; NOTEOFF = 1; POLYAT = 2; CONTROLCHANGE = 3; PROGCHANGE = 4;
CHANNELAT = 5; PITCHWHEEL = 6; EXCEPT = 7;

% -fk 25.02.04

data = zeros(1,2);

% open input file

fid = fopen(fname,'r');

if fid < 0
   disp(['midird3: Error opening MIDI file: ' fname]);
   return;
end

% check if output file (MIDIasText) is requested

if nargin > 1
   
   TXT = 1;
   fidtxt = fopen(txtname,'w');
   if fid < 0
   	disp('midird3: Error opening output file!');
      fclose(fid);
      return;
	end

else
   TXT = 0;
end

% read full MIDI file

smf = [fread(fid,inf,'uint8')' zeros(1,10)];
ptr = 1;

extptr = 1;
status = 255;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Read MIDI Track header
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ptr = NextValidHeader(ptr);

if(ptr <0 | ptr+4 > length(smf) | ptr+7 > length(smf))
   disp('Midi file format error on line 99 of midird3');
   fclose(fid);
   info = cell(0,0);
   midi = cell(0,0);
   ext  = cell(0,0);
   return;
end

len = Read32(smf(ptr+4:ptr+7));

ptr = ptr + 8;                % 'MThd' 

if(ptr <0 | ptr+1 > length(smf))
   disp('Midi file format error on line 110 of midird3');
   fclose(fid);
   info = cell(0,0);
   midi = cell(0,0);
   ext  = cell(0,0);
   return;
end
info.format = Read16(smf(ptr:ptr+1));

if(ptr <0 | ptr+2 > length(smf) | ptr+3 > length(smf))
   disp('Midi file format error on line 118 of midird3');
   fclose(fid);
   info = cell(0,0);
   midi = cell(0,0);
   ext  = cell(0,0);
   return;
end
info.ntrks  = Read16(smf(ptr+2:ptr+3));
if smf(ptr+4) < 0
   info.division.up = double(uint8(smf(ptr+4)));
   info.division.low = smf(ptr+5);
   info.division.main = inf;
else
   info.division.main = Read16(smf(ptr+4:ptr+5));
   info.division.up = inf;
   info.division.low = inf;
end

if TXT
   
   fprintf(fidtxt,'MIDI Header Chunk\n\n');
   fprintf(fidtxt,'MIDI File Format: %d \n',info.format);
   fprintf(fidtxt,'No. of Tracks: %d\n',info.ntrks);
   if smf(ptr+4) < 0
   	fprintf(fidtxt,'Time Division: (%d,%d)\n',[info.division.up info.division.low]);   
   else
      fprintf(fidtxt,'Time Division: %d\n',info.division.main);         
   end
   
end

ptr = ptr + len;					% 32BitLength,  the length should be 6 in SMFs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Read Tracks
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

midi = cell(1,info.ntrks);

abstime = 0;

for k = 1:info.ntrks
   
   if(ptr < 1 | ptr > length(smf))
      disp('Midi file format error on line 162 of midird3');
      fclose(fid);
      info = cell(0,0);
      midi = cell(0,0);
      ext  = cell(0,0);
      return;
   end
   
   ptr = NextValidHeader(ptr);
   
   if(ptr < 1 | ptr > length(smf))
      disp('Midi file format error on line 171 of midird3');
      fclose(fid);
      info = cell(0,0);
      midi = cell(0,0);
      ext  = cell(0,0);
      return;
   end

   
   ptrackstart = ptr;
   
   if TXT
      
      fprintf(fidtxt,'---------------------------------------------------------------------------\n');
      fprintf(fidtxt,'MIDI Track Chunk #%d\n\n',k-1);
      
   end
      
   s = sprintf('%s',smf(ptr:ptr+3));  
   if(~strcmp(s,'MTrk'))
       s = sprintf('midird3: MTrk expected, %s found!',smf(ptr:ptr+3));
      disp(s);
      return;
   end
   tracklen = Read32(smf(ptr+4:ptr+7));    % track length
   ptr = ptr + 8;									 % track start after header
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % start: process track
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   notes = zeros(tracklen,TUPLEN);				 % faster to create array at once
   notepos = 1;
   runningstatus.cmd = UNDEF;
   runningstatus.channel = UNDEF;
   actnotes = ones(1,TUPLEN)*-1;
   uniqueID = -2;
   
   if info.format ~= 2							 % Note: abstime (here) is independent of the
      abstime = 0;                         %       time signature which is eventually
   end												 %       present in the MIDI file (Meta Event)
   													 %       abstime only counts delta ticks
                                           
   while ptr <= ptrackstart + 8 + tracklen % start: track loop
      
      if(ptr+VLQLEN-1 <0 | ptr+VLQLEN-1 > length(smf)) 
         disp('Midi file format error on line 215 of midird3');
      	fclose(fid);
      	info = cell(0,0);
        midi = cell(0,0);
        ext  = cell(0,0);
	      return;
      end
      
      
      if(ptr <1 | (ptr+VLQLEN-1) > length(smf))
         info = cell(0,0);
         midi = cell(0,0);
         ext  = cell(0,0);
			disp('Midi file format error on line 224 of midird3');
         fclose(fid);
      	return;   
      end
      
      
      [delta,offs] = readvarlenintern(smf(ptr:ptr+VLQLEN-1));
      
      if(delta == 0 & offs == 0)
         info = cell(0,0);
         midi = cell(0,0);
         ext  = cell(0,0);
	     disp('Midi file format error on line 234 of midird3');
         fclose(fid);
      	return;   
      end
      
      abstime = abstime + delta;
      ptr = ptr+offs;
    
      eventstring = sprintf('%d\t\t\t\t',delta);         
         
      next = double(uint8(smf(ptr)));
      
      if(bitand(next,128))	 							 % status byte found if expn TRUE
         										    % evaluate new command (->running status)
         status = next;                                  
         if TXT                                 
             eventstring = [eventstring sprintf('Status %x ',next)];                                  
         end    
         channel = bitand(next,15);
                        
         switch bitand(next,240)					 % &F0
            
            case 144,				             % $90, NOTEON
               runningstatus.cmd = NOTEON;
               runningstatus.channel = channel;
               ptr = ptr + 1;
            case 128				             % $80, NOTEOFF
               runningstatus.cmd = NOTEOFF;  
               runningstatus.channel = channel;  
               ptr = ptr + 1;
            case 160,				 % $A0, POLYAT
               runningstatus.cmd = POLYAT;
               runningstatus.channel = channel;
               ptr = ptr + 1;
            case 176,				 % $B0, CONTROLCHANGE
               runningstatus.cmd = CONTROLCHANGE;
               runningstatus.channel = channel;
               ptr = ptr + 1;
            case 192,            % $C0, PROGCHANGE
               runningstatus.cmd = PROGCHANGE;
               runningstatus.channel = channel;
               ptr = ptr + 1;
			case 208,				 % $D0, CHANNELAT
               runningstatus.cmd = CHANNELAT;
               runningstatus.channel = channel;
            	ptr = ptr + 1;   
            case 224,				 % $E0, PITCHWHEEL
               runningstatus.cmd = PITCHWHEEL;
               runningstatus.channel = channel;
               ptr = ptr + 1;
            case 240,				 % $F0, EXCEPT
               runningstatus.cmd = EXCEPT;
               
         end    % switch
         
      end    % if
      
      % according to the MIDI-BNF there may be real-time events 
      % before each of the data bytes: we have overread them  
      
      statusnibble = bitand(double(uint8(next)),240)/16;
            
      if statusnibble<=14
         
         data = [];
         offset = 0;
         
         if (statusnibble == 12) | (statusnibble == 13)
            bytes = 1;
         else
            bytes = 2;
         end
         %[data,offset,eventstring] = GetDataBytes(bytes,ptr,eventstring,k);
         
         %%%%%%%%%%%%%%%%%%%%%%%
         data = zeros(1,2); offset = 0;
    	   found = 0;
    
		   while found < bytes
       
        	if(double(uint8(smf(ptr+offset)))<248)
         	  data(found+1) = double(uint8(smf(ptr+offset)));
              found = found + 1;
         	else
              eventstring = [eventstring sprintf('Sys Realtime: %x ',double(uint8(smf(ptr+offset))))];
          
 		      ext(extptr).track = k;
              ext(extptr).abstime = abstime;
              ext(extptr).midistring = smf(ptr+offset);
              extptr = extptr + 1;
         	end
         
            offset = offset + 1;
         end
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
         ptr = ptr + offset;
 
      end
 
      flag = 0;

      if (runningstatus.cmd == NOTEON) & (data(2)==0)
      
          runningstatus.cmd = NOTEOFF;
          flag = 1;
          
      end
      
      switch runningstatus.cmd
         
      	case NOTEON,
                        
            idx12 = max(find(actnotes(:,3)==data(1)& actnotes(:,6)==runningstatus.channel));
                            % note number
            
            if ~isempty(idx12)
               idx = find(actnotes(idx12,4)==notes(:,4));           % compare temporary unique ID
               notes(idx,4) = abstime-notes(idx,2); % new abstime        
               [sx,sy] = size(actnotes);
               if(idx12 == sx)
                      actnotes = [actnotes(1:idx12-1,:)];
               else
                      actnotes = [actnotes(1:idx12-1,:); actnotes(idx12+1:sx,:)]; 
               end      
            end
            
            if notepos == 1
                
                Delta = abstime;
                
            else 
                
                Delta = abstime - notes(notepos-1,2);
                
            end              
            
            actnotes = [actnotes; Delta abstime data(1) uniqueID data(2) ...
                  runningstatus.channel];
            notes(notepos,:) = [Delta abstime data(1) uniqueID data(2) ...
                  runningstatus.channel];
            notepos = notepos + 1;
            uniqueID = uniqueID - 1;
            
            if TXT
               eventstring = [eventstring sprintf('NOTE ON, Channel %d, Note # %d, Velocity %d ', ...
                 [runningstatus.channel data(1) data(2)])]; 
            end
            
         case NOTEOFF,
              
            idx12 = max(find(actnotes(:,3)==data(1)& actnotes(:,6)==runningstatus.channel));
            
            posn = max(1,notepos-7);
            if ~isempty(idx12) 
               idx = find(actnotes(idx12,4)==notes(posn:notepos,4))...
                      + posn-1; % compare temporary unique ID
               if isempty(idx)
                  idx = find(actnotes(idx12,4)==notes(1:posn,4));    
               end    
               notes(idx,4) = abstime-notes(idx,2); % new abstime         
               [sx,sy] = size(actnotes);
               if(idx12 == sx)
                      actnotes = [actnotes(1:idx12-1,:)];
               else
                      actnotes = [actnotes(1:idx12-1,:); actnotes(idx12+1:sx,:)]; 
               end      
              
            end
            
            if TXT
               eventstring = [eventstring sprintf('NOTE OFF, Channel %d, Note # %d, Velocity %d ', ...
                 [runningstatus.channel data(1) data(2)])]; 
            end
           
            if flag == 1
                
                flag = 0;
                runningstatus.cmd = NOTEON;
                
            end
                        
         case POLYAT,
            
            eventstring = [eventstring sprintf('POLYPHONIC AFTERTOUCH, Channel %d, Note # %d, AT-Pressure %d ', ...
                 [runningstatus.channel data(1) data(2)])]; 
           
           ext(extptr).track = k;
           ext(extptr).abstime = abstime;
           ext(extptr).midistring = [status data(1) data(2)];
           extptr = extptr + 1;
           
         case CONTROLCHANGE,
            
            eventstring = [eventstring sprintf('CONTROL CHANGE, Channel %d, Controller %d, Value %d ', ...
                 [runningstatus.channel data(1) data(2)])];               
           
           ext(extptr).track = k;
           ext(extptr).abstime = abstime;
           ext(extptr).midistring = [status data(1) data(2)];
           extptr = extptr + 1;

            switch(data(1))
               
            	case 7,
                  eventstring = [eventstring sprintf('(Main Volume) ')];
               case 39,
                  eventstring = [eventstring sprintf('(Main Volume) ')];
                     
            end     
            
            if((data(1)>=hex2dec('7B')) & (data(1)<=hex2dec('7F')))      % this implies/includes ALL NOTES OFF
                [lx,ly] = size(actnotes);
                for kk=2:lx
                 	idx = find(actnotes(kk,4)==notes(:,4));           % compare temporary
               	notes(idx,4) = abstime-notes(idx,2); % new abstime         % uniqueID              				      
                end    
                actnotes = ones(1,TUPLEN)*-1;

            end   
               
         case PROGCHANGE,
            
            eventstring = [eventstring sprintf('PROGRAM CHANGE, Channel %d, Program # %d ', ...
                 [runningstatus.channel data(1)])]; 
           
            ext(extptr).track = k;
            ext(extptr).abstime = abstime;
            ext(extptr).midistring = [status data(1)];
            extptr = extptr + 1;
 
         case CHANNELAT,
            
            eventstring = [eventstring sprintf('CHANNEL AFTERTOUCH, Channel %d, AT-Pressure # %d ', ...
                 [runningstatus.channel data(1)])]; 
           
            ext(extptr).track = k;
            ext(extptr).abstime = abstime;
            ext(extptr).midistring = [status data(1)];
            extptr = extptr + 1;

         case PITCHWHEEL,
              
     			eventstring = [eventstring sprintf('PITCH WHEEL CHANGE, Channel %d, MSB: %d, LSB: %d ', ...
                 [runningstatus.channel data(1) data(2)])];        
           
            ext(extptr).track = k;
            ext(extptr).abstime = abstime;
            ext(extptr).midistring = [status data(1) data(2)];
            extptr = extptr + 1;

         case EXCEPT,
              
            switch(next)
                                        
               case 240,				% $F0, SysExclusive
                    [len,offs] = readvarlenintern(smf(ptr+1:ptr+VLQLEN));
                    eventstring = [eventstring sprintf('SysEx %x, Length %d ', ...
                          [next len])];
                    ext(extptr).track = k;
                    ext(extptr).abstime = abstime;
                    ext(extptr).midistring = smf(ptr:ptr+offs+len);
                    extptr = extptr + 1;

                    ptr = ptr + 1 + offs + len;
                    
               case 255,				% $FF Meta event
                    metacmd = double(uint8(smf(ptr+1)));
                    [len,offs] = readvarlenintern(smf(ptr+2:ptr+VLQLEN+1));
						  eventstring = [eventstring sprintf('Meta %x ', ...
                             [next])];
                       
                    ext(extptr).track = k;
                    ext(extptr).abstime = abstime;
                    ext(extptr).midistring = smf(ptr:ptr+offs+len+1);
                    extptr = extptr + 1;
                     
                    if ((smf(ptr+1)>0) & (smf(ptr+1)<8))
                       
                       eventstring = [eventstring smf(ptr+2+offs:ptr+1+offs+len)];
                       
                    end   
                       
                    switch(smf(ptr+1))
               
            				case 0,
                  			eventstring = [eventstring sprintf('Sequence %d ',Read16(smf(ptr+3:ptr+4)))];
                        case 47            % hex2dec('2F'),
                  			eventstring = [eventstring sprintf('End of Track')];
                           [lx,ly] = size(actnotes);
                           for kk=2:lx
                           	idx = find(actnotes(kk,4)==notes(:,4));           % compare temporary
               					notes(idx,4) = abstime-notes(idx,2); % new abstime         % uniqueID              				      
                           end    
                           actnotes = ones(1,TUPLEN)*-1;
                        case 81,            % hex2dec('51'),
                           eventstring = [eventstring sprintf('Set Tempo %x%x%x ',...
                                 [double(uint8(smf(ptr+3:ptr+5)))])];
							   case 84,            % hex2dec('54'),
                           eventstring = [eventstring sprintf('SMPTE Offset %x %x %x %x ',...
                                 [double(uint8(smf(ptr+3:ptr+6)))])];
								case 88,            % hex2dec('58'),
                           eventstring = [eventstring sprintf('Time Signature %x %x %x %x ',...
                                 [double(uint8(smf(ptr+3:ptr+6)))])];
                    		case 89,            % hex2dec('59'),
                           eventstring = [eventstring sprintf('Key Signature sf: %d mi: %d ',[smf(ptr+3:ptr+4)])];
						  		case 127,           % hex2dec('7F'),
                           eventstring = [eventstring sprintf('Sequencer specific Meta, Length %d ',[len])];
                    end         
                    ptr = ptr + 2 + offs + len;	
                    
               case 247, 				% $F7, SysExclusive
                    [len,offs] = readvarlenintern(smf(ptr+1:ptr+VLQLEN));
						  eventstring = [eventstring sprintf('SysEx %x, Length %d ', ...
                 			[next len])];
                    
                    ext(extptr).track = k;
                    ext(extptr).abstime = abstime;
                    ext(extptr).midistring = smf(ptr:ptr+offs+len);
                    extptr = extptr + 1;
                    
                    ptr = ptr + 1 + offs + len;
                  
               case 241,  			% $F1, System Common (undef.)
                  	eventstring = [eventstring sprintf('System Common %x ', ...
                           [next])];
                     ptr = ptr + 3;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = 241;
                     extptr = extptr + 1;
               
               case 242,				% $F2, Song Position Pointer (SPP)
                  	eventstring = [eventstring sprintf('Song Position Pointer %x ', ...
                           [next])];
                     ptr = ptr + 3;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr:ptr+2);
                     extptr = extptr + 1;

                  
               case 243,				% $F3, Sys Common; Song Select (Song #)
                  	eventstring = [eventstring sprintf('Song Select %x ', ...
                           [next])];
							ptr = ptr + 2;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr:ptr+1);
                     extptr = extptr + 1;

                 
               case 244,				% $F4, Sys Common - undefined
                  	eventstring = [eventstring sprintf('System Common (undef.) %x ', ...
                           [next])];
                     ptr = ptr + 3;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr:ptr+2);
                     extptr = extptr + 1;
                  
               case 245,				% $F5, Sys Common - undefined
                  	eventstring = [eventstring sprintf('System Common (undef.) %x ', ...
                           [next])];
                     ptr = ptr + 3;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr:ptr+2);
                     extptr = extptr + 1;
                  
               case 246,				% $F6, Sys Common Tune Request
                    	eventstring = [eventstring sprintf('System Common Tune Request %x ', ...
                          [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;
                  
               case 248,				% $F8, Sys Real Time 
                    	eventstring = [eventstring sprintf('System Real Time %x ', ...
                             [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;
                  
               case 249,    			% $F9, Sys Real Time 
                    	eventstring = [eventstring sprintf('System Real Time %x ', ...
                             [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;
           
               case 250,				% $FA, Sys Real Time 
                    	eventstring = [eventstring sprintf('System Real Time %x ', ...
                             [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;
               
               case 251,				% $FB, Sys Real Time 
                    	eventstring = [eventstring sprintf('System Real Time %x ', ...
                             [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;

               case 252,				% $FC, Sys Real Time 
                    	eventstring = [eventstring sprintf('System Real Time %x ', ...
                             [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;
                
               case 253,				% $FD, Sys Real Time 
                    	eventstring = [eventstring sprintf('System Real Time %x ', ...
                             [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;
                 
               case 254, 				% $FE, Sys Real Time 
                    	eventstring = [eventstring sprintf('System Real Time %x ', ...
                             [next])];
                     ptr = ptr + 1;
                     ext(extptr).track = k;
                     ext(extptr).abstime = abstime;
                     ext(extptr).midistring = smf(ptr);
                     extptr = extptr + 1;           
             						  	                   
            end 
            
         otherwise,
            disp('midird3: Undefined running status!');
            disp('Position:');
            ptr
            if TXT
               eventstring = [eventstring sprintf('\n')];
         		fprintf(fidtxt,eventstring);
            	fprintf(fidtxt,'Code at Errorposition: %x \n',smf(ptr:ptr + 10));   
            	fclose(fidtxt);
            end
  				fclose(fid);
				return;
            
      end				% switch running status
      
      if TXT
         eventstring = [eventstring sprintf('\n')];
         fprintf(fidtxt,eventstring);
      end
      
   end				% End: track loop
   
   midi{k} = notes(1:notepos-1,:);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % end: process track
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   ptr = ptrackstart + 8 + tracklen;       % fwd to next track/chunk
   
end

if TXT
	fclose(fidtxt);
end   
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract tick resolution 
%
% ms_per_tick         milliseconds per tick
% ticks_per_quarter   ticks per quarter note
% ms_per_quarter      milliseconds per quarter note
%
% Determines the time per tick from the binary MIDI-data in ext.
% Additional functionality by Hinnerk Feldwisch and Meinard Müller
% added to midird3 by Frank Kurth, 11.05.2004
%
%>>>BEGIN>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

ticks_per_quarter = info.division.main;

exe = [];

for I=1:length(ext)
    ex=ext(I);
    if(max(abs(ex.midistring(1:2)-[255 81]))==0)
      exe = ex.midistring(4:end);
    end
end

if(length(exe) == 3)
    microsec_per_quarter = (exe(1) * 256 + exe(2)) * 256 + exe(3);
else
    microsec_per_quarter = 0;    % return zero, if no time-coding was found
end

ms_per_quarter = microsec_per_quarter/1000;      % == 0, if no time-coding was found  !
ms_per_tick = ms_per_quarter/ticks_per_quarter;  % == 0, if no time-coding was found  !

%<<<END<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% End of main program
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% At the moment, we know Chunks with the IDs 'MThd' and 'MTrk'
% The following function sets the pointer to the starting index within smf
% (it is assumed that the MIDI file is a contiguous sequence of chunks)
%

function p = NextValidHeader(pt)

global smf;


s = sprintf('%s',smf(pt:pt+3));
% DDD
%disp(s);
% DDD

while(~strcmp(s,'MThd') & ~strcmp(s,'MTrk'))
   if(pt < 1 | (pt+3) > length(smf))
      p = -1;
      return;
   end
   
   len = Read32(smf(pt:pt+3));
   pt = pt + 4 + 4 +len;           % HeaderId + 32BitLength + Length
   if pt > length(smf)
      p = -1;
      return
   end
end   

p = pt;
return;

%
% Read 4 Byte Word
%

function val = Read32(stream)

  val = double(uint8(stream(1)));

  for k = 2:4
  		val = val*256 + double(uint8(stream(k)));
  end   

return;

%
% Read 2 Byte Word
%

function val = Read16(stream)

	val = double(uint8(stream(1)))*256 + double(uint8(stream(2)));
 
return;

%
% overread real time messages
%

function [dat,offs,evstring] = GetDataBytes(byte,pt,evstring)

    global smf;
    global abstime;
    
    dat = zeros(1,2);
    offs = 0;
    found = 0;
    
    while found < byte
       
       if(double(uint8(smf(pt+offs)))<248)
          dat(found+1) = double(uint8(smf(pt+offs)));
          found = found + 1;
       else
         evstring = [evstring sprintf('Sys Realtime: %x ',double(uint8(smf(pt+offs))))];
       end
       offs = offs + 1;
       
    end
    
return;

%
% readvarleninternIntern
%

function [value,len] = readvarlenintern(stream)
% function [value,len] = readvarlenintern(stream)   read MIDI variable length quantity number
%
%  'value' returns the resulting Number, len is the number of values read from the
%  input smf-stream 'stream'
%
len = 1;
value = 0;
if(len > length(stream))
   value = 0;
   len = 0;
   return;
end

act = double(uint8(stream(len)));
value = act;
if(bitand(act,128))
   
   value = bitand(act,127);
   while bitand(act,128)
      len = len + 1;
      if(len > length(stream))
   		value = 0;
		   len = 0;
		   return;
		end
      act = double(uint8(stream(len)));
      value = value * 128 + bitand(act,127);
   end

end


