function h = plot_time_elec(stat, varargin)

% creates a plot with maskitsweet of 2d stat effects
% highlighting significant clusters

opt.pval = 0.05;
opt.ax = gca;
opt.nosig = 0.75;
opt.colors = [];

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
col = zeros(length(clst), 3);
for c = 1:length(clst)
    mask(clst(c).boolmat) = c;
end


% cluster colors
if femp(opt, 'colors') && logical(opt.colors) && opt.colors
    opt.colors = zeros(length(clst), 3);
    pn = [false, false];
    clst_col = [0, 0, 0; 0.4, 0.4, 0.4; ...
           1, 1, 1; 0.85, 0.85, 0.85];

    for c = 1:length(clst)
        if strcmp(clst(c).pol, 'pos')
            if pn(1)
                opt.colors(c,:) = clst_col(2,:);
            else
                opt.colors(c,:) = clst_col(1,:);
                pn(1) = true;
            end
        else
           if pn(2)
                opt.colors(c,:) = clst_col(4,:);
            else
                opt.colors(c,:) = clst_col(3,:);
                pn(2) = true;
            end
        end
    end
end

% get electrode ordering
ord = smart_order(true);
val = stat.stat(ord.order,:);
mask = mask(ord.order,:);


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