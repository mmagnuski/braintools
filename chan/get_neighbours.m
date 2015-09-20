function neighb = get_neighbours(captype)

supported_caps = {'EGI64'}; %, 'EasyCap64'};
which_cap = strcmp(captype, supported_caps);

if ~any(which_cap)
    error('Unsupported cap type');
end

base_path = fileparts(which('braintools'));
neigh_path = fullfile(base_path, 'chan', 'loc');
ld = load(fullfile(neigh_path, 'EGI64_Cz_neighbours.mat'));
neighb = ld.neighb.neighbours;