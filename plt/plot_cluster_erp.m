function plot_cluster_erp(clst, erp, time)

chan = get_cluster_chans(clst, 0.5);
timelims = find(any(clst.boolmat(chan, :), 1));
timelims = time(timelims([1, end]));

opts = {'LineWidth', 1.5};
plot(time, mean(erp{1}(chan,:), 1), 'g', opts{:});
hold on;
plot(time, mean(erp{2}(chan, :), 1), 'r', opts{:});
legend('compatible', 'incompatible');
ylim = get(gca, 'ylim');
x = timelims;
y = ylim;
vert = [x(1), y(1); x(2), y(1); x(2), y(2); x(1), y(2)];
p = patch('Vertices', vert, 'Faces', 1:4, 'FaceColor', ...
	[0.92, 0.92, 0.92], 'EdgeColor', 'none');
uistack(p, 'bottom');
line([0, 0], ylim, 'LineWidth', 3.5, ...
	'Color', 'k');