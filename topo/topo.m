function tp = topo(EEG, opt, varargin)

% simplifies topoplot API
% for example: topo(EEG, 'locs')
% brings up map of electrode locations
%
% topo(EEG, 'mark', chans);
% marks position of channels whose indices are 
% in chans variable

% TODOs:
% add more additional options like:
% 'numcontour'
% 'style' - default is 'blank' but in other contexts 'fill'

% figure;
if ischar(opt) && strcmp(opt, 'locs')
	topoplot([], EEG.chanlocs, 'style', 'blank', ...
                'electrodes', 'labelpoint', ...
                'chaninfo', EEG.chaninfo);
	tp = topo_scrapper(gca);
end
if ischar(opt) && strcmp(opt, 'mark')

    % get channel indices:
    chan_ind = varargin{1};
    if length(varargin) > 1
        varargin = varargin(2:end);
        opts = struct(varargin{:});
    else
        opts = struct();
    end

    if femp(opts, 'val')
        topoplot(opts.val, EEG.chanlocs, 'style', 'fill', ...
                'chaninfo', EEG.chaninfo, ...
                'electrodes', 'on');
        opts = rmfield(opts, 'val');
    else
        topoplot([], EEG.chanlocs, 'style', 'blank', ...
                'chaninfo', EEG.chaninfo, ...
                'electrodes', 'on');
    end
	tp = topo_scrapper(gca);
    % ADD rmfield below to remove options that markchans does not need
    markopt = struct_unroll(opts);
	tp = mark_chans(tp, chan_ind, markopt{:});
    delete(tp.elec_marks);
    tp = rmfield(tp, 'elec_marks');
end