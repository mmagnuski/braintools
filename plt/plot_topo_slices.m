function plot_topo_slices(stat, twin, ax, locs)

% PLOT_TOPO_SLICES plots topos of stat values
% from consecutive time windows in passed axes
% 

% defaults
pval     = 0.05;
elc_col  = [0, 0, 0];
title_font_size = 8;

% marker definition
marker.type    = '.';
marker.size    = 6;
marker.lw      = 0.5;
marker.edgecol = [0, 0, 0; 0, 0, 0];

% marker colors depending on polarity
posneg_cls_color = [[0, 0, 0];  ...
					[1, 1, 1] ];
% posneg_cls_color = [[243, 109, 116] / 255;  ...
% 					[0,   162, 232] / 255 ];

if marker.type == '.'
	marker.edgecol = posneg_cls_color;
end

% get clusters
clst{1} = get_cluster(stat, pval, 'pos');
clst{2} = get_cluster(stat, pval, 'neg');

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
		'LineWidth', 0.75);
	% change rim size:
	scale_topo_rim(h, 1.5);
	% change contour lines width
	set(h.hggroup, 'LineWidth', 0.1);

	% TODO
	% color electrodes with cluster
	delete(h.elec_marks);
	lineh = [0, 0];
	for c = 1:2
		if ~isempty(clst{c})

			% find cluster-participating electrodes
            elecs = [];
            for cc = 1:length(clst{c})
                addelecs = find(...
                    sum(clst{c}(cc).boolmat(:,win), 2) ...
                    > 0);
                elecs = unique([elecs, addelecs']);
            end
			if isempty(elecs)
				continue
			end

			% draw cluster electrode markers
			lineh(c) = line(...
				h.elec_pos(elecs, 1), ...
				h.elec_pos(elecs, 2), ...
				h.elec_pos(elecs, 3), ...
				'marker', marker.type, ...
				'linestyle', 'none', ...
				'markerfacecolor', posneg_cls_color(c,:), ...
				'markeredgecolor', marker.edgecol(c,:), ...
				'markersize', marker.size, ...
				'linewidth', marker.lw);

			% draw the rest of elecs?
		end
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