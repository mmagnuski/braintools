function h = plot_time_elec(stat, varargin)

% creates a plot with maskitsweet of 2d stat effects
% highlighting significant clusters
%
% plot_time_elec(stat, ...)
%
% optional arguments:
% -------------------
% pval   - significance threshold
% ax     - axis to plot in
% colors - cluster colors
% order  - how to order channels

opt.pval = 0.05;
opt.ax = gca;
opt.nosig = 0.75;
opt.colors = [];
opt.remove_chin = false;
opt.remove_Cz = false;
opt.order = true;
opt.maskopt = {};

if ~isempty(varargin)
    opt = parse_arse(varargin, opt);
end

%
tickFont = 9;
labFont  = 12;

% get clusters
clst = get_cluster(stat, opt.pval);

% create mask:
mask = zeros(size(stat.stat));
% col = zeros(length(clst), 3);
for c = 1:length(clst)
    mask(clst(c).boolmat) = c;
end


% cluster colors
if femp(opt, 'colors') && islogical(opt.colors) && opt.colors
    [~, opt.colors] = color_clusters(clst);
end


% get electrode ordering
if opt.order
    ord = smart_order(stat, opt);
    val = stat.stat(ord.order,:);
    mask = mask(ord.order,:);
else
    val = stat.stat;
end


% maskitsweet
maskopt = {'nosig', opt.nosig, 'lines', true, ...
    'LineColor', [0.5, 0.5, 0.5], ...
    'LineWidth', 0.5, 'Time', stat.time, ...
    'AxH', opt.ax};
maskopt = struct(maskopt{:});
maskopt.Cluster = true;
if femp(opt, 'colors')
    maskopt = rmfield(maskopt, 'LineColor');
    maskopt.LineWidth = 1;
    maskopt.ClusterColor = opt.colors;
end

maskopt = struct_unroll(maskopt);

% add opts from opt.maskopt
if femp(opt, 'maskopt') && iscell(opt.maskopt)
    maskopt = [maskopt, opt.maskopt];
end

[o, h] = maskitsweet(val, mask, maskopt{:});
h.clim = o.mapping([1, end])';

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
if opt.order
    lims = [ord.front_lim', ...
                ord.mid_lim', ...
                ord.back_lim'];
    Ytickpos = mean(lims, 1);

    % label y axis:
    set(gca, 'YTick', Ytickpos);
    set(gca, 'YTickLabel', {'anterior', 'central', 'posterior'});
end
% add division lines:
X = get(gca, 'XLim');
for i = 1:2
    Y = repmat(lims(2, i), [1, 2]);
    h.divlines(i) = line(X, Y+0.5, 'color', 'k', ...
        'linewidth', 0.5);
end

% label y axis
ylabel('Electrodes', 'FontSize', labFont);