function plot_line_col(t, lines, col)

gca;
hold on;
for l = 1:size(lines,2)
    plot(t, lines(:, l), 'color', col(l, :), 'linewidth', 2);
end