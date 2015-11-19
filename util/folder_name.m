function fld = folder_name(pth, fname)

% find folder with substring fname
% in path pth

fld = dir(pth);
fld = fld([fld.isdir]);

isit = ~cellfun(@isempty, strfind(...
    {fld.name}, fname));

if ~any(isit)
    fld = [];
    return
end

if sum(isit) == 1
    fld = fld(isit).name;
else
    fld = {fld(isit).name};
end
