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
try
	prob   = [stat.(fld).prob];
catch
	prob = [stat.(fld).p];
end
signif = find(prob < pval);

if ~isempty(signif)
	for s = 1:length(signif)
		% construct useful cluster fields
		clst(s).prob     = prob(signif(s));
		clst(s).boolmat  = stat.(fldmat) == signif(s);
		clst(s).samples  = find(sum(clst(s).boolmat > 0, 1));
		clst(s).nsamp    = length(clst(s).samples);
		clst(s).edges    = clst(s).samples([1, end]);
		clst(s).elecs    = find(sum(clst(s).boolmat > 0, 2));

        % chan labels
        try
            clst(s).label    = stat.label(clst(s).elecs);
        end
        % time labels
        try
            clst(s).time     = stat.time(clst(s).samples);
            clst(s).timedges = clst(s).time([1, end]);
        end 
	end
else
	clst = [];
end