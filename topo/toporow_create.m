function ax = toporow_create(fig, hlims, uplim, ntopo)

% TOPOROW_CREATE creates axes for topoplot
% images given constraints (hlims, uplim, ntopo)
% The axes have equal axis length (in what units?).
%
% ax = toporow_create(fig, hlims, uplim, ntopo)
%
% arguments
% ---------
% fig      - figure handle
% hlims - left, between_topo, right
%         (in pixels or normalized units)
% uplim - align topos to this upper limit
%         (in pixels or normalized units)
% ntopo - number of topo axes
%
% output
% ------
% ax - axes handles

% get pixel values
orig_units = get(fig, 'Units');
set(fig, 'Units', 'pixel');
pix_size   = get(fig, 'Position');
pix_size = pix_size(3:4);

% transform to pix:
if all(hlims <= 1)
	hlims = round(hlims * pix_size(1));
end
if uplim <= 1
	uplim = round(uplim * pix_size(2));
end

% calulate pix width of each ax:
hlen = round((pix_size(1) - sum(hlims([1, 3])) ...
		- hlims(2) * (ntopo - 1)) / ntopo);

ax = zeros(1, ntopo);

for a = 1:ntopo
	ax(a) = axes('units', 'pixel', ...
		'position', [hlims(1) + hlen * (a - 1) + ...
				hlims(2) * (a - 1), ...
				uplim - hlen, hlen, hlen]);
end

% return figure to original units
set(fig, 'Units', orig_units);

