function cfg = get_cfg_for_chan_nb_mat(EEG, neighb)

if isfield(EEG, 'elec')
    elec = EEG.elec;
else
    eeg = eeg2ftrip(EEG);
    elec = eeg.elec;
end

cfg.channel = elec.label;

if isfield(neighb, 'neighblabel')
    nb = neighb;
else
    nb = neighb.neighbours;
end

cfg.neighbours = nb;
cfg.avgoverchan = 'no';


    

    