function ver = mat_version(ifstruct)

if ~exist('ifstruct', 'var') || isempty(ifstruct)
    ifstruct = false;
end
ver = regexp(version(), 'R20[0-9]+[ab]', 'match');
ver = ver{1};
if ifstruct
    nver.y = str2num(ver(2:5)); %#ok<ST2NM>
    nver.l = ver(6);
    ver = nver;
end