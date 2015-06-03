function dat = sort_chans(dat)

% sort channels in alphabetical order
% (this is to prevent some fieldtrip bugs)
% works for fieldtrip data structures

if isfield(dat, 'label')
	% fieldtrip data
	[~, ord] = sort(dat.label);
	
	% sort labels
	dat.label = dat.label(ord);

	% sort data:
	for t = 1:length(dat.trial)
		dat.trial{t} = dat.trial{t}(ord, :);
	end

	% sort elec
	dat.elec.pnt = dat.elec.pnt(ord,:);
	dat.elec.label = dat.label;
else
	% eeglab data
	error(['sort_chans works only for fieldtrip ', ...
		'structures with label field present']);
end
