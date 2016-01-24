function EEG = add_chanlocs(EEG)

bt = fileparts(which('braintools'));
chan_pth = fullfile(bt, 'chan', 'loc', 'GSN-HydroCel-65 1.0.sfp');

EEG = pop_chanedit(EEG, 'load', chan_pth, 'changefield', ...
	{68, 'datachan', 0}, 'setref', {'1:67', 'Cz'});
