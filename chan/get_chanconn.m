function chanconn = get_chanconn(EEG, captype)

neighb = get_neighbours(captype);
cfg = get_cfg_for_chan_nb_mat(EEG, neighb)
chanconn = makechanneighbstructmat(cfg);
