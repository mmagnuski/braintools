function h = topo_scrapper(ax)

% TOPO_SCRAPPER disects EEGlab's topoplot axis structure
% and exposes handles to easily navigate and manipulate
% parts of the topoplot
% 
% warning! this works correct for normal filled
% topoplot (was not tested for other topoplot types)


% get children:
chld = get(ax, 'Children');
tps  = get(chld, 'Type');

% test lines for being of none linestyle
lns = chld(strcmp('line', tps));
lnstl = get(lns, 'linestyle'); 
elcs = strcmp('none', lnstl);
shps = find(~elcs); elcs = find(elcs);
ptch = find(strcmp(tps, 'patch'));

% at the top are electrode markers
h.elec_marks   = chld(elcs(1));
if length(elcs) > 1
	h.elec_marks2  = chld(elcs(2));
end
h.left_ear     = chld(shps(1));
h.right_ear    = chld(shps(2));
h.nose         = chld(shps(3));

if length(shps) > 3
    h.head         = chld(shps(4));
else
    h.head = chld(ptch(1));
    ptch(1) = [];
end

% get electrode positions:
flds = {'elec_pos', 'elec_pos2'; ...
		'elec_marks', 'elec_marks2'};
for i = 1:length(elcs)
	h.(flds{1, i})    = [...
		get(h.(flds{2,i}), 'X')', ...
		get(h.(flds{2,i}), 'Y')', ...
		get(h.(flds{2,i}), 'Z')'];
end

h.one_elec_group = length(elcs) == 1;


% get title
h.title       = get(ax, 'title');

% patch and hggroup:
h.patch = chld(ptch(1));
h.hggroup = chld(strcmp('hggroup', tps));

% may be interesting to disect the hggroup into 
% contour and image etc...