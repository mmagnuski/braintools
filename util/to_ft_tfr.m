function tfr = to_ft_tfr(EEG, matrix)

if ~isfield(EEG, 'label')
    eeg = eeg2ftrip(EEG);
else
    eeg = EEG;
end
sz = size(matrix);

tfr = struct();
tfr.label = eeg.label(1:sz(1));
tfr.dimord = 'chan_freq_time';
tfr.freq = 1:sz(2);
if length(sz) == 3
    tfr.time = 1:sz(3);
else
    tfr.time = [0.];
end
tfr.powspctrm = matrix;

tfr.elec.chanpos = eeg.elec.pnt(1:sz(1), :);
tfr.elec.elecpos =tfr.elec.chanpos;
tfr.elec.label = tfr.label;

