function chan = get_cluster_chans(clst, partic, varargin)

% return a list of channel indices that constitute
% the cluster, given participation criterion.
% The participation criterion is minimum % of max
% cluster time.

if ~exist('partic', 'var')
    partic = 0.33;
end
opt.time = false;
if nargin > 2
    opt = parse_arse(varargin, opt);
end

if ~opt.time
    get_samples = 1:length(clst.samples);
else
    get_samples = cnt(find_range(clst.time, opt.time));
end

chan = find(mean(clst.boolmat(:, clst.samples(get_samples)), ...
	2) >= partic);
