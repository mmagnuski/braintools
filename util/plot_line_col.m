function hl = plot_line_col(t, lines, col, opts)

gca;
hold on;
hl = [];

if exist('opts', 'var')
    for l = 1:size(lines,2)
        hl(l) = plot(t, lines(:, l), 'color', col(l, :), opts{:}); %#ok<*AGROW>
    end
else
    for l = 1:size(lines,2)
        hl(l) = plot(t, lines(:, l), 'color', col(l, :));
    end
end    