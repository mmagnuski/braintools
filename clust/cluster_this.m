function [pos, neg] = cluster_this(data, thresh, chanconn, min_chan)

% TODO
% if thresh is a matrix the same size as data:
% - use it as a p-value map and look for < 0.05

% cluster positive eff
if ~exist('min_chan', 'var')
    min_chan = 1;
end
pos = data > thresh;
clust = findcluster(pos, chanconn, min_chan);

vals = compute_cluster_val(clust, data, @sum);
if ~isempty(vals)
	pos = max(vals);
else
	pos = 0;
end

% cluster negative eff
neg = data < (thresh * -1);
clust = findcluster(neg, chanconn, min_chan);

vals = compute_cluster_val(clust, data, @sum);
if ~isempty(vals)
	neg = min(vals);
else
	neg = 0;
end