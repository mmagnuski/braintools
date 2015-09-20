% TOPOS
% -----
% get topo timewindows
ntopo = 6;
twin  = get_time_windows(stat{ef}, 0.05, ntopo);
twin.times = round(twin.times * 1000); % to ms

% create topo axes
uplim = 0.5;
hlims = [0.08, 0.05, 0.08];
ax    = toporow_create(h.fig, hlims, uplim, ntopo);

% create topo in each ax:
locs = get_relevant_locs(EEG, stat{ef});
plot_topo_slices(stat{ef}, twin, ax, locs);