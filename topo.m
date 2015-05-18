function topo(EEG, opt)

% simplifies topoplot API
% for example: topo(EEG, 'locs')
% brings up map of electrode locations

figure;
if strcmp(opt, 'locs')
	topoplot([], EEG.chanlocs, 'style', 'blank', ...
                'electrodes', 'labelpoint', ...
                'chaninfo', EEG.chaninfo);
end