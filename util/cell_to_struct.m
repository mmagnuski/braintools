function s = cell_to_struct(c)

if iscell(c)
    flds = fields(c{1});
    len = length(c);
    opts = cell(length(flds) * 2, 1);
    opts(1:2:end) = flds;
    opts{2} = cell(len, 1);
    s = struct(opts{:})';

    for ii = 1:len
        for f = 1:length(flds)
            s(ii).(flds{f}) = c{ii}.(flds{f});
        end
    end
else
    s = c;
end