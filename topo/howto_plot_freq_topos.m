% plot two rows of topos
% first for 12 - 15 Hz
% second for 8 - 11 Hz

% extract cluster and add color
c = get_cluster(stat);
c.color = [1,1,1];

% create time windows
twin.samples = bsxfun(@plus, [0:2:10]', [1, 3]);
twin.times = stat.time(twin.samples);

% get EEG file for chanlocs
PTH = 'D:\Dropbox\CURRENT PROJECTS\N170 Olga';
fls = dir(fullfile(PTH, 'SET', '*.set'));
eeg_path('add')
EEG = pop_loadset(fullfile(dtpth, fls(1).name));

% plot everything
opt = {'electreshold', 0.1, 'markersize', 14};
f = figure('Position', [30, 150, 1200, 400]);
ax = toporow_create(f, [0.1, 0.025, 0.1], 0.95, 6);
plot_topo_slices(stat, c, twin, ax, EEG.chanlocs, 'freq', [12, 15], opt{:});

ax = toporow_create(f, [0.1, 0.025, 0.1], 0.5, 6);
plot_topo_slices(stat, c, twin, ax, EEG.chanlocs, 'freq', [8, 11], opt{:});