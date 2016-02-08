function cfg = get_cfg_for_chan_nb_mat(neighb, EEG)

hasEEG = true;
if ~exist('EEG', 'var')
    hasEEG = false;
end

if hasEEG
    if isfield(EEG, 'elec')
        elec = EEG.elec;
    else
        eeg = eeg2ftrip(EEG);
        elec = eeg.elec;
    end
    cfg.channel = elec.label;
else
    cfg.channel = {neighb.label};
end

if isfield(neighb, 'neighblabel')
    nb = neighb;
else
    nb = neighb.neighbours;
end

cfg.neighbours = nb;
cfg.avgoverchan = 'no';

