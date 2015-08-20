function stat = cluster_correct_ttest2(data, cond, statfun, n_perm)

if ~exist('n_perm', 'var')
    n_perm = 1000;
end

shuffle = @(x) x(randperm(length(x), length(x)));
cfg = get_cfg_for_chan_nb_mat(EEG, neighb);
chan_nb = makechanneighbstructmat(cfg);

neg_dist = zeros(n_perm, 1);
pos_dist = zeros(n_perm, 1);
for i = 1:n_perm
    cond = shuffle(emo);
    
    [~, p, ~, stat] = ttest2(t_rshp(cond,:,:), ...
        t_rshp(~cond,:,:));
    t_prm = squeeze(stat.tstat(1,:,:));
    p_prm = squeeze(p(1,:,:));
    
    cluster = findcluster(p_prm < 0.05, ...
        chan_nb);
    vals = compute_cluster_val(cluster, t_prm, @sum);
    neg_dist(i) = min(vals);
    pos_dist(i) = max(vals);
    if mod(i, 10) == 0
        fprintf('%d\n', i);
    end
end