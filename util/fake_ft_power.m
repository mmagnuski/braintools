function tfr = fake_ft_power(data, freq, chan_names)

tfr.label = chan_names;
tfr.dimord = 'chan_freq';
tfr.freq = freq;
tfr.powspctrm = data;

n_chan = length(chan_names);
tfr.elec.label = chan_names;
tfr.elec.chanpos = zeros(n_chan, 3);
tfr.elec.elecpos = tfr.elec.chanpos;
tfr.elec.unit = 'cm';
