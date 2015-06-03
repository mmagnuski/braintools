function tp = mark_chans(tp, elecs, varargin)

if ~isempty(varargin)
	varopts = struct(varargin{:});
else
	varopts = struct();
end

mark.marker = '.';
mark.markersize = 23;
mark.markeredgecolor = [0.8, 0.4, 0.2];

for f = fields(varopts)'
	mark.(f{1}) = varopts.(f{1});
end

opts = struct_unroll(mark);

% check chanmarks_ field
basefld = 'chanmarks_';
flds = fields(tp);
previous = ~cellfun(@isempty, cellfun(@(x) strfind(x, basefld), flds, ...
	'UniformOutput', false));
fname = [basefld, num2str(sum(previous) + 1)];

tp.(fname) = line( ...
    tp.elec_pos(elecs, 1), ...
    tp.elec_pos(elecs, 2), ...
    tp.elec_pos(elecs, 3), ...
    'linestyle', 'none', ...
    opts{:} ...
);
