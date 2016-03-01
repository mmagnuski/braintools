function EEG = add_chanlocs(EEG, captype)

bt = fileparts(which('braintools'));
captypes = {'EGI64', 'EasyCap64'};
cap2fl = {'GSN-HydroCel-65 1.0.sfp', 'EasyCap_locs.txt'};

if ~exist('captype', 'var') || isempty(captype)
    captype = 'EGI64';
end

which_cap = find(strcmp(captype, captypes));
locfile = cap2fl{which_cap}; %#ok<FNDSB>

chan_pth = fullfile(bt, 'chan', 'loc', locfile);

if strcmp(captype, 'EGI64')
    EEG = pop_chanedit(EEG, 'load', chan_pth, 'changefield', ...
        {68, 'datachan', 0}, 'setref', {'1:67', 'Cz'});
elseif strcmp(captype, 'EasyCap64')
    EEG = pop_chanedit(EEG, 'load', {chan_pth, 'filetype', 'sph'});
end