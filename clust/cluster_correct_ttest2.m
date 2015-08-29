function stat = cluster_correct_ttest2(data, orig_cond, chan_nb, n_perm)

% cluster_correct_ttest2(data, orig_cond, chan_nb, n_perm)
% computes cluster-correction (Maris, Oostenveld, 2007)
% on between subjects data
% 
%
% inputs
% ------
% data - subjects by dims
% orig_cond - original conditions that subjects belong to
% chan_nb - channel neighbourhood
% n_perm  - number of permutations
%
% outputs
% -------
% stat    - FieldTrip compatible stat structure
%
% see also: cluster_this

if ~exist('n_perm', 'var')
    n_perm = 1000;
end

orig_size = size(data);
needs_reshape = length(orig_size) > 2;
shuffle = @(x) x(randperm(length(x), length(x)));

neg_dist = zeros(n_perm, 1);
pos_dist = zeros(n_perm, 1);
for i = 1:n_perm
    cond = shuffle(orig_cond);

    [~, p, ~, stat] = ttest2(data(cond,:), ...
        data(~cond,:));
    t_prm = squeeze(stat.tstat(1,:));
    p_prm = squeeze(p(1,:));
    
    % test for reshape
    if needs_reshape
        t_prm = reshape(t_prm, orig_size(2:end));
        p_prm = reshape(p_prm, orig_size(2:end));
    end
    if size(p_prm, 1) == 1 && length(size(p_prm)) < 3
        p_prm = p_prm(:);
        t_prm = t_prm(:);
    end
    
    cluster = findcluster(p_prm < 0.05, chan_nb);
    vals = compute_cluster_val(cluster, t_prm, @sum);
    
    neg = vals < 0;
    if any(neg)
        neg_dist(i) = min(vals(neg));     
    else
        neg_dist(i) = 0;
    end
    pos = vals > 0;
    if any(pos)
        pos_dist(i) = max(vals(pos));     
    else
        pos_dist(i) = 0;
    end
        
    if mod(i, 10) == 0
        fprintf('%d\n', i);
    end
end

%  original effect
[~, p, ~, stat] = ttest2(data(orig_cond,:), ...
    data(~orig_cond,:));
t_prm = squeeze(stat.tstat(1,:));
p_prm = squeeze(p(1,:));

% test for reshape
if needs_reshape
    t_prm = reshape(t_prm, orig_size(2:end));
    p_prm = reshape(p_prm, orig_size(2:end));
end
if size(p_prm, 1) == 1 && length(size(p_prm)) < 3
    p_prm = p_prm(:);
    t_prm = t_prm(:);
end

clst = findcluster(p_prm < 0.05, chan_nb);
vals = compute_cluster_val(clst, t_prm, @sum);

% compute p-vals
% --------------
clst_p = zeros(1, length(vals));

% pos and neg
pos = vals > 0;
clst_p(pos) = arrayfun(@(x) mean(x < pos_dist) * 2, ...
    vals(pos));
neg = vals < 0;
clst_p(neg) = arrayfun(@(x) mean(x > neg_dist) * 2, ...
    vals(neg));


stat = [];
stat.clusterlabelmat = clst;
stat.tvalue = vals;
stat.pvalue = clst_p;
stat.stat = t_prm;
