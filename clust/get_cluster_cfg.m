function cfg = get_cluster_cfg(varargin)

if ~isempty(varargin)
	ifdep = any(strcmp('dep', varargin));
else
	ifdep = false;
end

cfg            = [];
cfg.correctm   = 'cluster';
cfg.method     = 'montecarlo';
cfg.minnbchan  = 0;

cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.alpha            = 0.05;
cfg.clusteralpha     = 0.05;
cfg.correcttail      = 'prob';
cfg.clusterstatistic = 'maxsum'; 
cfg.statistic        = 'indepsamplesT';
cfg.tail             = 0;
cfg.clustertail      = 0;

% currently not defined:
% cfg.channel  = chansel;
% cfg.time or cfg.latency
% cfg.frequency  = [7, 13];
% cfg.neighbours = neighb;

cfg.design           = [];
cfg.ivar             = 1;
cfg.feedback         = 'textbar';
cfg.computeprob      = 'yes';

if ifdep
	cfg.statistic = 'depsamplesT';
	cfg.uvar = 2;
end