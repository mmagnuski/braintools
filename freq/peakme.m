function dataout = peakme(data, freq, n)

% NOHELPINFO

if ~exist('n', 'var')
    n = 3;
end

freq_ind = find_range(data.freq, freq);
dataout = data;

dims = strsep(data.dimord, '_');
if ~strcmp(dims{1}, 'chan')
	error('First dimension must be equal to channels');
end

numchan = size(data.powspctrm, 1);
peak_Hz = zeros(numchan, 1);
dataout.powspctrm = peak_Hz;
for ch = 1:numchan
	pk = peakness(n, data.powspctrm(ch, :), freq_ind);
	peak_Hz(ch) = data.freq(pk);
	dataout.powspctrm(ch, 1) = data.powspctrm(ch, pk);
end
dataout.peak_Hz = peak_Hz;
dataout.freq = mean(freq);
