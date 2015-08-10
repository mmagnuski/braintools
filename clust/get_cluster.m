function clst = get_cluster(stat, pval, pol)

% GET_CLUSTER get cluster info from stat structure:
% cluster edges, electrodes participating in the cluster etc.
% FIXHELPINFO

% TODOs:
% [ ] turn into an object with lazy+persistent param evaluation

if ~exist('pol', 'var')
    pol = 'pos';
end

if ~exist('pval', 'var')
    pval = 0.05;
end

% clusterslabelmat (pos) or (neg):
fld = [pol, 'clusters'];
fldmat = [fld, 'labelmat'];

% check probability
prob   = [stat.(fld).prob];
signif = find(prob < pval);

if ~isempty(signif)
	% currently take only the first one
	signif = signif(1);

	% construct useful cluster fields
	clst.prob     = prob(signif);
	clst.boolmat  = stat.(fldmat) == signif;
	clst.samples  = find(sum(clst.boolmat > 0, 1));
	clst.nsamp    = length(clst.samples);
	clst.time     = stat.time(clst.samples);
	clst.edges    = clst.samples([1, end]);
	clst.timedges = clst.time([1, end]);
	clst.elecs    = find(sum(clst.boolmat > 0, 2));
	clst.label    = stat.label(clst.elecs);
else
	clst = [];
end