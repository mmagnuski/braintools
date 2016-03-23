function neighb = get_neighbours(captype)

supported_caps = {'egi64', 'biosemi32'}; %, 'EasyCap64'};
which_cap = strcmp(lower(captype), supported_caps);
cap_neighbours = {'EGI64_Cz_neighbours.mat', 'BioSemi32_neighbours.mat'};

if ~any(which_cap)
    error('Unsupported cap type');
end

base_path = fileparts(which('braintools'));
neigh_path = fullfile(base_path, 'chan', 'loc');
ld = load(fullfile(neigh_path, cap_neighbours{which_cap}));
try
    neighb = ld.neighb.neighbours;
catch %#ok<CTCH>
    neighb = ld.neighbours;
end