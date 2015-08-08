function cover_topo_half(tp, varargin)

x = get(tp.patch, 'XData');
y = get(tp.patch, 'YData');

if nargin > 1
	col = varargin{1};
else
	col = [1, 1, 1];
end

len = round(length(x) / 4);
x = x(1:len);
y = y(1:len);
% add z data so that patch is on top
z = ones(len, 1) * 10;

patch('Vertices', [x, y, z], 'Faces', 1:len, ...
	'FaceColor', col, 'EdgeColor', 'none');
