function chan = get_cluster_chans(clst, partic)

if ~exist('partic', 'var')
    partic = 0.33;
end

chan = find(mean(clst.boolmat(:, clst.samples), ...
	2) >= partic);