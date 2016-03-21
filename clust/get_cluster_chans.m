function chan = get_cluster_chans(clst, partic)

% return a list of channel indices that constitute
% the cluster, given participation criterion.
% The participation criterion is minimum % of max
% cluster time.

if ~exist('partic', 'var')
    partic = 0.33;
end

chan = mean(clst.boolmat(:, clst.samples), ...
	2) >= partic;
chan = clst.elecs(chan);