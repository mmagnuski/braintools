function mask = get_cluster_mask(stat, pval)

if ~exist('pval', 'var')
    pval = 0.05;
end
pos_clst = get_cluster(stat, pval, 'pos');
neg_clst = get_cluster(stat, pval, 'neg');

% create mask:
mask = false(size(stat.stat));

if isstruct(pos_clst)
    for s = 1:length(pos_clst)
        mask = mask | pos_clst(s).boolmat;
    end
end
if isstruct(neg_clst)
    for s = 1:length(neg_clst)
        mask = mask | neg_clst(s).boolmat;
    end
end