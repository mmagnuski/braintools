function scale_topo_rim(topo, scaleby)

% changes the width of the EEGlab's topoplot rim
% (one that covers ugly-looking edges and
% makes the plot look smooth) in the inward
% direction
% the topo passed to the function as input is
% a structure of handles obtained by disecting
% a topoplot with topo_scrapper
% 
% usage:
% scale_topo_rim(topo);
% scale_topo_rim(topo, scaleby);
%
% Example:
% topo = topo_scrapper(topoplot_axis_handle);
% scale_topo_rim(topo);
% 
% see also: topoplot, topo_scrapper

if ~exist('scaleby', 'var')
    scaleby = 1.25;
end
if ~(scaleby > 1)
	error('currently scaleby must be more than one.');
end

% get patch xdata and ydata:
x = get(topo.patch, 'XData');
y = get(topo.patch, 'YData');

rim_width = y(1) - y(end);
rim_radius = y(end); % 
target_width = rim_width * scaleby;

% calculate
add_width = target_width - rim_width;
relative  = add_width / rim_radius;
weight    = 1 - relative;

num_points = length(x);
half_num   = num_points / 2;

x(half_num + 1 : end) = x(half_num + 1 : end) * weight + ...
	repmat(0, [half_num, 1]) * relative;
y(half_num + 1 : end) = y(half_num + 1 : end) * weight + ...
	repmat(0, [half_num, 1]) * relative;

set(topo.patch, 'XData', x);
set(topo.patch, 'YData', y);