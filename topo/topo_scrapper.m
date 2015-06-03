function h = topo_scrapper(ax)

% TOPO_SCRAPPER disects EEGlab's topoplot axis structure
% and exposes handles to easily navigate and manipulate
% parts of the topoplot
%
% input
% -----
% ax - handle to the topoplot's axis
%
% output
% ------
% h  - structure of (mostly) handles to topoplot 
%      graphical elements. Contains following fields:
%  .elec_marks - FIXHELPINFO
%  .left_ear
%  .right_ear
%  .nose
%  .head
%  .title
%  .patch
%  .hggroup
%  .text
%  .elec_labels
%  .label
% 
% example
% -------
% removing the nose:
%     topoplot(values, EEG.chanlocs);
%     tp = topo_scrapper(gca);
%     delete(tp.nose);


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
h.elec_marks   = lns(elcs(1));
if length(elcs) > 1
	h.elec_marks2  = lns(elcs(2));
end
h.left_ear     = lns(shps(1));
h.right_ear    = lns(shps(2));
h.nose         = lns(shps(3));

if length(shps) > 3
    h.head         = lns(shps(4));
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
if ~isempty(ptch)
    h.patch = chld(ptch(1));
else
    h.patch = [];
end
h.hggroup = chld(strcmp('hggroup', tps));

% check text labels:
tmp = findobj('parent', ax, 'type', 'text');
if ~isempty(tmp)
    h.text = tmp(end-1:end);
    if length(tmp) > 2
        h.elec_labels = tmp(1:end-2);
        h.label = get(h.elec_labels, 'string');
        h.label = cellfun(@deblank, h.label, ...
            'UniformOutput', false);
    end
else
    h.elec_labels = [];
end

% may be interesting to disect the hggroup into 
% contour and image etc...