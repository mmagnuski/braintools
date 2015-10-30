function plot_topo_slices(stat, clst, twin, ax, locs, varargin)

% PLOT_TOPO_SLICES plots topos of stat values
% from consecutive time windows in passed axes
% 

% defaults
pval     = 0.05;
elc_col  = [0, 0, 0];
title_font_size = 8;

% marker definition
opt.markertype    = '.';
opt.markersize    = 6;
opt.markerlw      = 0.5;
opt.toposhapelw   = 0.75;
opt.topocontourlw = 0.1;

% check timeunits
opt.timeunits = 'ms';
if mean(diff(stat.time)) < 0.3
	opt.timeunits = 's';
end

if nargin > 5
	opt = parse_arse(varargin, opt);
end


% bothbool = clst{1}.boolmat | clst{2}.boolmat;
scalelim = [min(min(stat.stat)), max(max(stat.stat))];

% plot each timeslice
for t = 1:size(twin.samples, 1)
	
	% get window indices and effect value
	win  = twin.samples(t,1) : twin.samples(t,2);
	effect = mean(stat.stat(:, win), 2);

	% topoplot
	axes(ax(t));
	topoplot(effect, locs, ...
		'style', 'fill', ...
	    'numcontour', 8, ...
	    'maplimits', scalelim);

	% add title about time
	title(sprintf('%d - %d ms', ...
		twin.times(t,1), twin.times(t,2)),...
		'fontsize', title_font_size);
	
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
        elecs = find(sum(clst(c).boolmat(:,win), 2) > 0);

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
			'linewidth', opt.markerlw);

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