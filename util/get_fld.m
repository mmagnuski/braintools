function out = get_fld(s, fld, def)

% out = get_fld(struct, fields, def)
% get field values from struct if present, otherwise return def

if ~exist('def', 'var')
    def = [];
end

if ischar(fld)
	fld = {fld};
end

if ~iscell(fld)
	error('fld must be character or cell');
end

f = fields(s);
chck = cellfun(@(x) any(strcmp(x, f)), fld);
sumchck = sum(chck);

if sumchck == 0
	return def
else
	ind = find(sumchck);
	if sumchck > 1
		warning(['More than one field matches those searched ', ...
			'for, taking contents of first one.']);
		ind = ind(1);
	end
	return s.(f{ind})
end
