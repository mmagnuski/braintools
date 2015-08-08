function braintools()

% add paths to braintools

pth = fileparts(mfilename('fullpath'));
addpath(pth);

fld = {'util', 'freq', 'topo', 'chan', 'plt'};
cellfun(@(x) addpath(fullfile(pth, x)), fld);