function h = plot_time_elec(stat, varargin)

% creates a plot with maskitsweet of 2d stat effects
% highlighting significant clusters

opt.pval = 0.05;
opt.ax = gca;
opt.nosig = 0.75;

if ~isempty(varargin)
    opt = parse_arse(varargin, opt);
end

%
tickFont = 9;
labFont  = 12;

% get clusters
pos_clst = get_cluster(stat, opt.pval, 'pos');
neg_clst = get_cluster(stat, opt.pval, 'neg');

% create mask:
mask = false(size(stat.stat));

if isstruct(pos_clst)
    for s = 1:length(pos_clst)
        mask = mask | pos_clst(s).boolmat;
    end
end
if isstruct(neg_clst)
    for s = 1:length(neg_clst)
        mask = mask | neg_clst(s).boolmat;
    end
end

% get electrode ordering
ord = smart_order(true);
val = stat.stat(ord.order,:);
mask = mask(ord.order,:);


% maskitsweet
maskopt = {'nosig', 0.65, 'lines', true, ...
    'LineColor', [0.5, 0.5, 0.5], ...
    'LineWidth', 0.5, 'Time', stat.time, ...
    'AxH', opt.ax, 'nosig', opt.nosig};
maskitsweet(val, mask, maskopt{:});
[~, h] = maskitsweet(val, mask, maskopt{:});


% finishing up
% ------------
% y dir back to inverted
set(gca, 'YDir', 'reverse');

% remove y ticks and change their length
tickl = get(gca, 'TickLength');
tickl([1, 2]) = 0.01;
set(gca, 'TickLength', tickl);
set(gca, 'FontSize', tickFont);

% label x axis
xlabel('Time (seconds)', 'FontSize', labFont);

% get tick pos for y:
lims = [ord.front_lim', ...
            ord.mid_lim', ...
            ord.back_lim'];
Ytickpos = mean(lims, 1);

% label y axis:
set(gca, 'YTick', Ytickpos);
set(gca, 'YTickLabel', {'anterior', 'central', 'posterior'});

% add division lines:
X = get(gca, 'XLim');
for i = 1:2
    Y = repmat(lims(2, i), [1, 2]);
    h.divlines(i) = line(X, Y+0.5, 'color', 'k', ...
        'linewidth', 0.5);
end

% label y axis
ylabel('Electrodes', 'FontSize', labFont);