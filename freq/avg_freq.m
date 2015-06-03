function data = avg_freq(data, freq_range)

% 

cnt = @(x) x(1):x(2);
middle_freq = mean(freq_range);
rng = cnt(rangefind(data.freq, freq_range));

if strcmp(data.dimord, 'chan_freq')
    data.powspctrm = mean(data.powspctrm(:, rng), 2);
    data.freq = middle_freq;
end