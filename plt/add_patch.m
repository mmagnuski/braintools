function h = add_patch(xlims, color, where)

% add_patch(xlims, color, where)
% adds patch to the current axis of specified xlims.
% Most useful when trying to mark significant regions.

if ~exist('color', 'var')
    color = [0.8, 0.8, 0.8];
end

if ~exist('where', 'var')
    where = 'below';
end

% get xlims and ylims:
ax = gca();
xl = get(ax, 'xlim');
yl = get(ax, 'ylim');

% create patch vertices
vert = [xlims(1), yl(1);...
        xlims(2), yl(1);...
        xlims(2), yl(2);...
        xlims(1), yl(2);...
        ];

% faces
fc = 1:4;

% create patch
h = patch('vertices', vert, 'faces', fc, ...
    'facecolor', color, 'edgecolor', 'none');

% put the patch below
if isequal(where, 'below')
    hs = get(ax, 'Children');

    % find the patch:
    where = hs == h;

    hs = [hs(~where); h];
    set(ax, 'Children', hs);
end