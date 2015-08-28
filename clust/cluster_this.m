function [pos, neg] = cluster_this(data, thresh, chanconn)

% if thresh is a matrix the same size as data:
% - use it as a p-value map and look for < 0.05
% TODO

% cluster positive eff
pos = data > thresh;
clust = findcluster(pos, chanconn, 1);
NCl = max(max(clust));

vals = compute_cluster_val(clust, data, @sum);
if ~isempty(vals)
	pos = max(vals);
else
	pos = 0;
end

% cluster negative eff
neg = data < (thresh * -1);
clust = findcluster(neg, chanconn, 1);
NCl = max(max(clust));

vals = compute_cluster_val(clust, data, @sum);
if ~isempty(vals)
	neg = min(vals);
else
	neg = 0;
end