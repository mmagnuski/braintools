function h = erp_plot(EEG, erp, varargin)

sz = size(erp);
if sz(2) > sz(1)
	erp = erp';
end

opt.patch = [];
opt.color = [];
if nargin > 2
    opt = parse_arse(varargin, opt);
end

if isempty(opt.color)
h.erp = plot(EEG.times, erp, 'linewidth', 2.5);
else
    h.erp = plot(EEG.times, erp, 'linewidth', 2.5, ...
        'color', opt.color);
end
hold on
h.xline = plot(EEG.times([1, end]), [0, 0], ...
	'Linewidth', 2, 'color', [0.75, 0.75, 0.75]);
uistack(h.xline, 'bottom');
ylm = get(gca, 'ylim');
h.yline = plot([0, 0], ylm, ...
	'Linewidth', 2, 'color', [0.75, 0.75, 0.75]);
uistack(h.yline, 'bottom');
set(gcf, 'color', [1,1,1]);

% add patches
if ~isempty(opt.patch)
    hlfsamp = diff(EEG.times([1, 2])) / 2;
    g = group(opt.patch);
    % take only significant:
    g = g(g(:,1) == 1, 2:3);
    g = EEG.times(g);
    g = [g(:,1) - hlfsamp, g(:,2) + hlfsamp];
    for ip = 1:size(g, 1)
        add_patch(g(ip,:), [0.9, 0.9, 0.9]);
    end
end
    