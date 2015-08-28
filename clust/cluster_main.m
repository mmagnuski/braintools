function stat = cluster_main(data, chanconn, posdist, negdist, fun, minch)

if ~exist('fun', 'var')
    fun = @sum;
end
if ~exist('minch', 'var')
    minch = 1;
end

stat = [];
stat.stat = data;

% positive
pos = data > 2;
posclust = findcluster(pos, chanconn, minch);
NCl = max(max(posclust));

pos_vals = compute_cluster_val(posclust, data, fun);
pos_p = arrayfun(@(x) mean(posdist > x), pos_vals) * 2; % two-tail!

% get p value order:
[pos_p, ord] = sort(pos_p);
deal_pos_p = num2cell(pos_p);
deal_pos_val = num2cell(pos_vals(ord));

stat.posclusters = struct('p', deal_pos_p, 'val', deal_pos_val);
stat.posclusterslabelmat = renum_mat(posclust, ord);


% negative
neg = data < -2;
negclust = findcluster(neg, chanconn, minch);
NCl = max(max(negclust));

neg_vals = compute_cluster_val(negclust, data, fun);
neg_p = arrayfun(@(x) mean(negdist < x), neg_vals) * 2; % two-tail!

% get p value order:
[neg_p, ord] = sort(neg_p);
deal_neg_p = num2cell(neg_p);
deal_neg_val = num2cell(neg_vals(ord));

stat.negclusters = struct('p', deal_neg_p, 'val', deal_neg_val);
stat.negclusterslabelmat = renum_mat(negclust, ord);