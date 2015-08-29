function cfg = get_cluster_cfg(varargin)

if length(varargin) > 0
	ifdep = any(strcmp('dep', varargin));
else
	ifdep = false;
end

cfg            = [];
% cfg.channel  = chansel;
cfg.correctm   = 'cluster';
cfg.method     = 'montecarlo';
% cfg.neighbours = neighb;
% cfg.frequency  = [7, 13];
cfg.minnbchan = 0;               

cfg.numrandomization = 1000;
cfg.correctm         = 'cluster';
cfg.alpha            = 0.05;
cfg.clusteralpha     = 0.05;
cfg.correcttail      = 'prob';
cfg.clusterstatistic = 'maxsum'; 
cfg.statistic        = 'indepsamplesT';
cfg.tail             = 0;
cfg.clustertail      = 0;

% cfg.design           = log10(bdi_score' + 0.005);
cfg.design           = [];
cfg.ivar             = 1;
cfg.feedback         = 'textbar';
cfg.computeprob      = 'yes';

if ifdep
	cfg.statistic = 'depsamplesT';
	cfg.uvar = 2;
end