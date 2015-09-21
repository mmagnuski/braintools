function locs = get_relevant_locs(EEG, stat)

% gives the EEG.chanlocs that are present in stat

locs = EEG.chanlocs;
electrodes_id = eeg_findelec(EEG, stat.label);
locs = locs(electrodes_id);