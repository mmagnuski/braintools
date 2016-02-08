function tp = mark_chans(tp, elecs, varargin)

% mark channels in a given topoplot 
%
% inputs
% ------
% tp - topolot handles returned byt topo_scrapper
% elecs - electrode indices
% 
% optional key-value inputs
% -------------------------
% marker - string, matlab-style, for example '.' (default is '.')
% markersize - numeric; size of the marker (default: 23)
% markeredgecolor - 1x3 RGB vector (default: [0.8, 0.4, 0.2])
%                   or Nx3 RGB vector where N is the same as 
%                   number of marked channels
%                   or Nx1 vector of values - will use
%                   markercolormap in this case for color
% 
% output
% ------
% tp - structure of topoplot handles with a field storing
%      handles to the marked channels

if ~isempty(varargin)
	varopts = struct(varargin{:});
else
	varopts = struct();
end

mark.marker = '.';
mark.markersize = 23;
mark.markeredgecolor = [1, 1, 1];
mark.markerfacecolor = [1, 1, 1];
mark.markercolormap = 'hot';

for f = fields(varopts)'
	mark.(f{1}) = varopts.(f{1});
end
mrsz = size(mark.markeredgecolor);
if mrsz(1) == 1 && (mrsz(2) == 2 || mrsz(2) > 3)
    mark.markeredgecolor = mark.markeredgecolor';
end
multichan_color = size(mark.markeredgecolor, 1) > 1;
cmap_chan_color = false;
if multichan_color
    cmap_chan_color = size(mark.markeredgecolor, 2) == 1;
end

% check chanmarks_ field
basefld = 'chanmarks_';
flds = fields(tp);
previous = ~cellfun(@isempty, cellfun(@(x) strfind(x, basefld), flds, ...
	'UniformOutput', false));
fname = [basefld, num2str(sum(previous) + 1)];

if ~multichan_color
    mark = rmfield(mark, 'markercolormap');
    opts = struct_unroll(mark);
    tp.(fname) = line( ...
        tp.elec_pos(elecs, 1), ...
        tp.elec_pos(elecs, 2), ...
        tp.elec_pos(elecs, 3), ...
        'linestyle', 'none', ...
        opts{:} ...
    );
else
    if cmap_chan_color
        cmap = feval(mark.markercolormap, 256);
        ind = round(mark.markeredgecolor * 256);
        ind(ind<=0) = 1;
        ind(ind>=256) = 256;
        mark.markeredgecolor = cmap(ind, :);
    end
    nchan = length(elecs);
    vec = zeros(1, nchan);
    
    mcolor = mark.markeredgecolor;
    mark = rmfield(mark, 'markeredgecolor');
    mark = rmfield(mark, 'markercolormap');
    opts = struct_unroll(mark);
    for c = 1:nchan
        vec(c) = line( ...
        tp.elec_pos(elecs(c), 1), ...
        tp.elec_pos(elecs(c), 2), ...
        tp.elec_pos(elecs(c), 3), ...
        'linestyle', 'none', ...
        'markeredgecolor', mcolor(c, :), ...
        opts{:});
    end
    tp.(fname) = vec;
end
        
