function channeighbstructmat = makechanneighbstructmat(cfg)

% MAKECHANNEIGHBSTRUCTMAT makes the makes the matrix containing the channel
% neighbourhood structure.
% by Robert Ooostenveld

% because clusterstat has no access to the actual data (containing data.label), this workaround is required
% cfg.neighbours is cleared here because it is not done where avgoverchan is effectuated (it should actually be changed there)
if strcmp(cfg.avgoverchan, 'no')
  nchan=length(cfg.channel);
elseif strcmp(cfg.avgoverchan, 'yes')
  nchan = 1;
  cfg.neighbours = [];
end
channeighbstructmat = false(nchan,nchan);
for chan=1:length(cfg.neighbours)
  [seld] = match_str(cfg.channel, cfg.neighbours(chan).label);
  [seln] = match_str(cfg.channel, cfg.neighbours(chan).neighblabel);
  if isempty(seld)
    % this channel was not present in the data
    continue;
  else
    % add the neighbours of this channel to the matrix
    channeighbstructmat(seld, seln) = true;
  end
end;