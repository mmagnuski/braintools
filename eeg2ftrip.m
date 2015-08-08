% eeg2ftrip()
% Usage:    >> data = eeg2ftrip( EEG );
%
% Inputs:
%   EEG       - [struct] EEGLAB structure
%
% Outputs:
%   data    - FIELDTRIP structure
%
% Originally written by: Robert Oostenveld, F.C. Donders Centre, May, 2004.
%                        Arnaud Delorme, SCCN, INC, UCSD
% Modified by:           Miko³aj Magnuski
%
% See also: 

% Copyright (C) 2004 Robert Oostenveld, F.C. Donders Centre, roberto@smi.auc.dk
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function data = eeg2ftrip(EEG, varargin)

% start with an empty data object 
data = [];

% check input
if nargin == 1
    fieldbox = 'preprocessing';
elseif nargin > 1
    fieldbox = 'freqanalysis';
    freqopt = varargin{1};
end

% add the objects that are common to all fieldboxes
tmpchanlocs  = EEG.chanlocs;
data.label   = { tmpchanlocs.labels };
data.fsample = EEG.srate;


data.elec.pnt   = zeros(length( EEG.chanlocs ), 3);
for ind = 1:length( EEG.chanlocs )
    data.elec.label{ind} = EEG.chanlocs(ind).labels;
    if ~isempty(EEG.chanlocs(ind).X)
        data.elec.pnt(ind,1) = EEG.chanlocs(ind).X;
        data.elec.pnt(ind,2) = EEG.chanlocs(ind).Y;
        data.elec.pnt(ind,3) = EEG.chanlocs(ind).Z;
    else
        data.elec.pnt(ind,:) = [0 0 0];
    end;
end;

        
switch fieldbox
  case 'preprocessing'
      sampt = 1000/EEG.srate;
      samptimes = EEG.times/sampt;
      data.sampleinfo = zeros(EEG.trials,2);
      lastsamp = 0;
      
    for index = 1:EEG.trials
      data.trial{index}  = EEG.data(:,:,index);
      % ADD - time added as EEG.times only when
      % not assumed consecutive
      data.time{index}   = EEG.times/1000; 
      noepinf = true;
      
      if ~isempty(EEG.epoch) && ~isempty(EEG.epoch(index).event)
          % check event (could be held in numeric or cell array)
          if isnumeric(EEG.epoch(index).eventlatency)
            zeroev = EEG.epoch(index).eventlatency == 0;
            zeroev = EEG.epoch(index).eventurevent(zeroev);
          elseif iscell(EEG.epoch(index).eventlatency)
              zeroev = find(cellfun(@(x) x == 0, ...
                  EEG.epoch(index).eventlatency), 1, 'first');
              zeroev = EEG.epoch(index).eventurevent{zeroev};
          end
          if iscell(zeroev)
              zeroev = zeroev{1};
          end
          if ~(zeroev > length(EEG.urevent))
              noepinf = false;
          origlat = EEG.urevent(zeroev).latency;
          data.sampleinfo(index, 1) = samptimes(1) + origlat;
          data.sampleinfo(index, 2) = samptimes(end) + origlat;
          lastsamp = data.sampleinfo(index, 2);
          end
      end
      if noepinf
          % assuming consecutive:
          data.sampleinfo(index, 1) = lastsamp + 1;
          data.sampleinfo(index, 2) = lastsamp + length(EEG.times);
          lastsamp = lastsamp + length(EEG.times);
      end
      
      % ADD - moving trial event info
    end;

  case 'freqanalysis'
    switch freqopt.method
        case 'pwelch'
            data = SpectPwelch(EEG, freqopt);
    end
    
  otherwise
    error('unsupported fieldbox') 
end

try
  % get the full name of the function
  data.cfg.version.name = mfilename('fullpath');
catch %#ok<CTCH>
  % required for compatibility with Matlab versions prior to release 13 (6.5)
  [st, i] = dbstack;
  data.cfg.version.name = st(i);
end

% add the version details of this function call to the configuration
data.cfg.version.id   = '$Id: eeglab2fieldtrip.m,v 1.6 2009-07-02 23:39:29 arno Exp $';

return
