function tfr = to_ft_tfr(EEG, matrix)

eeg = eeg2ftrip(EEG);
sz = size(matrix);

tfr = struct();
tfr.label = eeg.label(1:sz(1));
tfr.dimord = 'chan_freq_time';
tfr.freq = 1:sz(2);
tfr.time = 1:sz(3);
tfr.powspctrm = matrix;

tfr.elec.chanpos = eeg.elec.pnt(1:sz(1), :);
tfr.elec.elecpos =tfr.elec.chanpos;
tfr.elec.label = tfr.label;

