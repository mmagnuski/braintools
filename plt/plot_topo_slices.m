function plot_topo_slices(stat, clst, twin, ax, locs, varargin)

% PLOT_TOPO_SLICES plots topos of stat values
% from consecutive time windows in passed axes
% 
% plot_topo_slices(stat, clst, twin, ax, locs)
%
% twin - structure containing:
%     .samples - sample limits of time windows
%     .times - time limits of time windows

% TODOs:
% [ ] - check chan overlap

% defaults
% pval     = 0.05;
opt.titles = true;

% marker definition
opt.markertype    = '.';
opt.markersize    = 6;
opt.markerlw      = 0.5;
opt.toposhapelw   = 0.75;
opt.topocontourlw = 0.1;
opt.electreshold  = 0.2;
opt.style         = 'fill';
opt.numcontour    = 8;
opt.gridscale     = 128;
opt.freq = [];
opt.clim = [];
opt.style = 'fill';
opt.titlefontsize = 8;

% check timeunits
opt.timeunits = 'ms';
if mean(diff(stat.time)) < 0.3
	opt.timeunits = 's';
end

if nargin > 5
	opt = parse_arse(varargin, opt);
end

% check dimensions of stat - if more than 2d - we need to reduce
moredims = false;
if ndims(stat.stat) > 2 %#ok<ISMAT>
	moredims = true;
	dims = strsep(stat.dimord, '_');
	whichfreq = find(strcmp(dims, 'freq'));
	if ~isempty(opt.freq)
		freqr = find_range(stat.freq, opt.freq);
		freqr = freqr(1):freqr(2);
		stat.stat = squeeze(mean(stat.stat(:, freqr, :), whichfreq));
		for c = 1:length(clst)
			clst(c).boolmat = squeeze(mean(clst(c).boolmat(:, freqr, :), whichfreq));
		end
	else
		error('your data has more than 2 dimensions but freq was not specified');
	end
end

timstr = '%d - %d ms';
if strcmp(opt.timeunits, 's')
	timstr = '%4.3f - %4.3f s';
end

% bothbool = clst{1}.boolmat | clst{2}.boolmat;
% opt.clim controls limits of colormap
if isempty(opt.clim)
    opt.clim = [min(min(stat.stat)), max(max(stat.stat))];
end

% plot each timeslice
for t = 1:size(twin.samples, 1)

	% get window indices and effect value
	win  = twin.samples(t,1) : twin.samples(t,2);
	effect = mean(stat.stat(:, win), 2);

	% topoplot
	axes(ax(t)); %#ok<LAXES>
	topoplot(effect, locs, ...
		'style', opt.style, ...
	    'numcontour', opt.numcontour, ...
	    'maplimits', opt.clim, ...
        'gridscale', opt.gridscale);

	% add title about time
    set(ax(t), 'units', 'normalized');
	if opt.titles
		time_text = sprintf(timstr, ...
			twin.times(t,1), twin.times(t,2));
		title_h = title(time_text,...
			'fontsize', opt.titlefontsize);
		if strcmp(opt.titles, 'below')
			xl = get(ax(t), 'xlim');
            yl = get(ax(t), 'ylim');
			set(title_h, 'Position', ...
				[mean(xl), yl(1) - 0.15], ...
				'HorizontalAlignment', 'center');
% 				'VerticalAlignment', 'bottom', ...
		end
	end

	% disect topoplot
	h = topo_scrapper(ax(t));

	% change line width
	set([h.left_ear, h.right_ear, h.nose, h.head], ...
		'LineWidth', opt.toposhapelw);
	% change rim size:
	scale_topo_rim(h, 1.5);
	% change contour lines width
	set(h.hggroup, 'LineWidth', opt.topocontourlw);

	% TODO
	% color electrodes with cluster
	delete(h.elec_marks);
    for c = 1:length(clst)
        % find cluster-participating electrodes
        if moredims
            elecs = find(mean(clst(c).boolmat(:,win), 2) > opt.electreshold);
        else
            % ADD - if electreshold defined -
            % take mean and compare to tresh
            elecs = find(sum(clst(c).boolmat(:,win), 2) > 0);
        end

        if isempty(elecs)
            continue
        end

        % draw cluster electrode markers
        lineh(c) = line(...
            h.elec_pos(elecs, 1), ...
            h.elec_pos(elecs, 2), ...
            h.elec_pos(elecs, 3), ...
            'marker', opt.markertype, ...
            'linestyle', 'none', ...
            'markerfacecolor', clst(c).color, ...
            'markeredgecolor', clst(c).color, ...
            'markersize', opt.markersize, ...
            'linewidth', opt.markerlw); %#ok<AGROW,NASGU>

        % draw the rest of elecs?
    end

    % move ears etc. below lines
    % lineh(lineh == 0) = [];
    % if ~isempty(lineh)
    % 	chld = get(ax(t), 'Children');
    % 	marks_in_chld = arrayfun(@(x) find(chld == x), lineh);
    % 	chld(marks_in_chld) = [];
    % 	chld = [lineh'; chld]; %#ok<AGROW>
    % 	% chld = [chld; lineh']; %#ok<AGROW>
    % 	set(ax(t), 'Children', chld);
    % end
end