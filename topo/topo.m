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
                'chaninfo', EEG.chaninfo, ...
                'electrodes', 'on');
	tp = topo_scrapper(gca);
    chan_ind = varargin{1};
    if length(varargin) > 1
        varargin = varargin(2:end);
    else
        varargin = [];
    end
	tp = mark_chans(tp, chan_ind, varargin);
end