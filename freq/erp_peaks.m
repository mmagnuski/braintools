function [peak_val, peak_lat] = erp_peaks(EEG, ranges, rangedir, cond)

% NOHELPINFO

n = 4;
num_rng = length(ranges);
if ~exist('cond', 'var')
    cond = ones(EEG.trials, 1);
end
if ~(length(cond) == EEG.trials)
	error('The length of cond does not match the number of trials.');
end
if mod(num_rng, 2)
	error('There must be two range limits for each range.');
else
	num_rng = num_rng / 2;
end
if ~(num_rng == length(rangedir))
	error('rangedir must correspond to number of ranges.');
end

numchan = size(EEG.data, 1);
rng = reshape(find_range(EEG.times, ranges), [2, num_rng])';
cond_unique = unique(cond);
num_cond = length(cond_unique);

peak_val = nan(numchan, num_rng, num_cond);
peak_lat = peak_val;

for c = 1:num_cond
	erp = give_erp(EEG, 'all', find(cond == cond_unique(c)));
	for ch = 1:numchan
		for r = 1:num_rng
            if rangedir(r) == 0
                [pk1, pkn1] = peakness(n, erp(ch,:), rng(r,:));
                [pk2, pkn2] = peakness(n, -1*erp(ch,:), rng(r,:));
                % get higher peakness
                [~, which] = max([pkn1, pkn2]);
                allpeak = [pk1, pk2];
                pk = allpeak(which);
            else
                pk = peakness(n, rangedir(r)*erp(ch,:), rng(r,:));
            end
            if ~isempty(pk)
                peak_lat(ch, r, c) = EEG.times(pk);
                peak_val(ch, r, c) = erp(ch, pk);
            end
		end
	end
end
