function trackout = MergeTracks(tracksin)
% function trackout = MergeTracks(tracksin)     merge tracks given as cell array tracksin
%
%  Function midird returns the note information within a cell array. 
%  This function merges all MIDI tracks in tracksin while maintaining
%  time consistency.
%

TUPLEN = 6;       % important:  # components of the midi n-tuple

if ~iscell(tracksin)
   trackout = tracksin;
   return
end

ntrks = length(tracksin);
lx = zeros(1,ntrks);
ct = 1;

for k=1:ntrks
   [lx(k),ly] = size(tracksin{k});
   if ly ~= TUPLEN
      disp('MergeTracks: mismatch between TUPLEN and array size');
      return;
   end
   if lx(k) ~= 0
      trackin{ct} = tracksin{k};
      trackmax(ct) = lx(k);
      ct = ct + 1;   
   end
      
end

ntrks = ct - 1;
trackptr = ones(1,ntrks);
tmp = zeros(ntrks,TUPLEN);
trackout = zeros(sum(lx),TUPLEN);

for k=1:ntrks
   tmp(k,:) = trackin{k}(1,:);
end

abstime = 0;

for k = 1:sum(lx)

   nexttime = min(tmp(:,2)-abstime);
   idx = find(nexttime == (tmp(:,2)-abstime));
   idx = idx(1);
   
   trackout(k,:) = tmp(idx,:);
   trackout(k,1) = nexttime;
   abstime = trackout(k,2);
   
   trackptr(idx) = trackptr(idx) + 1;

   if trackptr(idx) > trackmax(idx)
      tmp(idx,2) = inf;
   else      
      tmp(idx,:) = trackin{idx}(trackptr(idx),:);
   end   
      
end



