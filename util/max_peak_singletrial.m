function outdat = max_peak_singletrial(EEG, rngs, dirct)

% get the peaks
EEG = zscore_channels(EEG);
erps = give_erp(EEG, 'all', []);

% if ranges not given, look for p100 and n170
if ~exist('rngs', 'var')
	rngs = [70, 145; 140, 200];
	dirct = [1, -1];
end
if ~exist('dirct', 'var')
    dirct = ones(size(rngs,1), 1);
end
unroll = @(x) x(:);
outdat = zeros(EEG.trials, size(rngs,1));
[pv, pl] = erp_peaks(EEG, unroll(transpose(rngs)), dirct);

for p = 1:size(rngs,1)
	r = find_range(EEG.times, rngs(p,:));
    goodchans = find(~isnan(pv(:,p)));
	chanmax = max(erps(goodchans, r(1):r(2)) * dirct(p), [], 2);
	[~, chan] = max(chanmax);
    chan = goodchans(chan);
	t = pl(chan,p);
	lat = find(EEG.times == t);

	outdat(:, p) = EEG.data(chan, lat, :); %#ok<FNDSB>
end
