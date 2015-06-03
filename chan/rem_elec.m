function data = rem_elec(data, elec)

% removes electrodes from EEG structure
% (currently supports only EEGlab data format)

elec_names = {data.chanlocs.labels};

if ischar(elec)
	elec = find(strcmp(elec, elec_names));
elseif iscell(elec)
	tmp = cellfun(@(x) find(strcmp(x, elec_names)), ...
		elec, 'UniformOutput', false);

	% issue a warining if not all electrodes present

	elec = [tmp{:}];
end

if ~isempty(elec)
	num_rem = length(elec);
	data.nbchan = data.nbchan - num_rem;

	data.data(elec, :, :) = [];
	data.chanlocs(elec) = [];
    
	% urchan field does not give index in urchanlocs
    % currently we are not removing channels from urchanlocs
	% data.urchanlocs(rem_ur) = [];
    % but maybe we should
    
end

		