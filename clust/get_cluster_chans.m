function chan = get_cluster_chans(clst, partic, varargin)

% return a list of channel indices that constitute
% the cluster, given percentage participation criterion.
%
% usage:
% chan = get_cluster_chans(clst) % default 33% criterion
% chan = get_cluster_chans(clst, partic)
%
% arguments:
% clst   - cluster, structure returned by get_cluster
% partic - participation criterion, minimum % of max
%          cluster time.
%
% optional key-value arguments:
% 'time' - vector of [min max] time range within which
%          to get channels contributing to cluster

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
% chan = clst.elecs(chan);
