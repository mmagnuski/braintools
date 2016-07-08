function EEG = add_chanlocs(EEG, captype)

bt = fileparts(which('braintools'));
captypes = {'EGI64', 'EasyCap64'};
cap2fl = {'GSN-HydroCel-65 1.0.sfp', 'EasyCap_locs.txt'};

if ~exist('captype', 'var') || isempty(captype)
    captype = 'EGI64';
end

if ~strcmpi(captype, 'auto')
    which_cap = find(strcmp(captype, captypes));
    locfile = cap2fl{which_cap}; %#ok<FNDSB>

    chan_pth = fullfile(bt, 'chan', 'loc', locfile);

    if strcmp(captype, 'EGI64')
        EEG = pop_chanedit(EEG, 'load', chan_pth, 'changefield', ...
            {68, 'datachan', 0}, 'setref', {'1:67', 'Cz'});
    elseif strcmp(captype, 'EasyCap64')
        EEG = pop_chanedit(EEG, 'load', {chan_pth, 'filetype', 'sph'});
    end
else
    dipfit_path = get_eeglab_plugin_path('dipfit');
    lookup_path = fullfile(dipfit_path, ...
        'standard_BESA\\standard-10-5-cap385.elp');

    % add chanloc
    EEG = pop_chanedit(EEG, 'lookup', lookup_path);
end