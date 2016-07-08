function chanconn = get_chanconn(captype, EEG)

if ischar(captype)
    neighb = get_neighbours(captype);
elseif isstruct(captype)
    neighb = captype;
end

if exist('EEG', 'var')
    cfg = get_cfg_for_chan_nb_mat(neighb, EEG);
else
    cfg = get_cfg_for_chan_nb_mat(neighb);
end
chanconn = makechanneighbstructmat(cfg);
