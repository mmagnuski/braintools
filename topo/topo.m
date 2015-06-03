function tp = topo(EEG, opt, varargin)

% simplifies topoplot API
% for example: topo(EEG, 'locs')
% brings up map of electrode locations

% if ~isempty(varargin)
% 	varopts = struct(varargin);
% else
% 	varopts = struct();
% end

figure;
if ischar(opt) && strcmp(opt, 'locs')
	topoplot([], EEG.chanlocs, 'style', 'blank', ...
                'electrodes', 'labelpoint', ...
                'chaninfo', EEG.chaninfo);
	tp = topo_scrapper(gca);
end
if ischar(opt) && strcmp(opt, 'mark')

	topoplot([], EEG.chanlocs, 'style', 'blank', ...
                'chaninfo', EEG.chaninfo);
	tp = topo_scrapper(gca);
	tp = mark_chans(tp, varargin);
end