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
    if ischar(chan_ind)
        chan_ind = {chan_ind};
    end
    if iscell(chan_ind)
        chan_ind = find_elec(EEG, chan_ind);
    end

    if length(varargin) > 1
        varargin = varargin(2:end);
        opts = struct(varargin{:});
    else
        opts = struct();
    end
    
    if femp(opts, 'maplimits')
        topo_opt.maplimits = opts.maplimits;
        opts = rmfield(opts, 'maplimits');
    else
        topo_opt.maplimits = 'absmax';
    end

    if femp(opts, 'val')
        topo_opt = struct_unroll(topo_opt);
        topoplot(opts.val, EEG.chanlocs, ...
                'chaninfo', EEG.chaninfo, ...
                'electrodes', 'on', topo_opt{:});
        opts = rmfield(opts, 'val');
    else
        topoplot([], EEG.chanlocs, 'style', 'blank', ...
                'chaninfo', EEG.chaninfo, ...
                'electrodes', 'on');
    end
    
    % use shorter keyword - color, that means markeredgecolor
    if femp(opts, 'color')
        opts.markeredgecolor = opts.color;
        opts = rmfield(opts, 'color');
    end
    
	tp = topo_scrapper(gca);
    % ADD rmfield below to remove options that markchans does not need
    markopt = struct_unroll(opts);
	tp = mark_chans(tp, chan_ind, markopt{:});
    delete(tp.elec_marks);
    tp = rmfield(tp, 'elec_marks');
end
if isnumeric(opt)
    topoplot(opt(:), EEG.chanlocs);
end