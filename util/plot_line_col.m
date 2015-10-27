function plot_line_col(t, lines, col, opts)

gca;
hold on;
if exist('opts', 'var')
    for l = 1:size(lines,2)
        plot(t, lines(:, l), 'color', col(l, :), opts{:});
    end
else
    for l = 1:size(lines,2)
        plot(t, lines(:, l), 'color', col(l, :));
    end
end    