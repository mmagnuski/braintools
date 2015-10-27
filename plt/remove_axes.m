function frontax = remove_axes(ah, color)

if ~exist('color', 'var')
    color = [1, 1, 1];
end

props = {'parent', 'xlim', 'ylim', 'position', ...
    'xtick', 'ytick'};
vals = cell(1, length(props)*2);
vals(2:2:end) = get(ah, props);
vals(1:2:end) = props;

frontax = axes(vals{:}, 'color', 'none');
set(frontax, 'XTick', [], 'YTick', [], ...
    'XColor', color, 'YColor', color, ...
    'box', 'on', 'layer', 'top');

