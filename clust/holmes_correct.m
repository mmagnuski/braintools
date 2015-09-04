function [holmes_stat, any_significant] = holmes_correct(stat, holmes_stat)

any_significant = false;
if ~exist('holmes_stat', 'var') || isempty(holmes_stat)
    holmes_stat = struct();
    holmes_stat.num_pos = 0;
    holmes_stat.num_neg = 0;
    holmes_stat.iter = 1;
    holmes_stat.stat = stat.stat;
    holmes_stat.mask = false(size(stat.stat));
    holmes_stat.posclusterslabelmat = zeros(size(stat.stat));
    holmes_stat.negclusterslabelmat = zeros(size(stat.stat));
else
    holmes_stat.iter = holmes_stat.iter + 1;
end

for fld = {'posclusters', 'negclusters'}
    lbmat = [fld{1}, 'labelmat'];
    p_vals = [stat.(fld{1}).p];
    which_clusters = find(p_vals < 0.05);
    num_signif_clusters = length(which_clusters);
    if num_signif_clusters > 0
        any_significant = true;

        % update holmes_mask
        rshp_clusters = reshape(which_clusters, [1,1,num_signif_clusters]);
        signif_map = sum(bsxfun(@eq, stat.(lbmat), rshp_clusters), 3) > 0;
        holmes_stat.mask = holmes_stat.mask | signif_map;

        % move signif clusters to holmes_stat
        for hcl = which_clusters
            clst_ind = holmes_stat.(['num_', fld{1}(1:3)]) + 1;

            % add cluster p_val, stat_val
            clst_stat = stat.(fld{1})(hcl);
            clst_stat.holmes_iter = holmes_stat.iter;
            holmes_stat.(fld{1})(clst_ind) = clst_stat;

            % add cluster labelmat
            holmes_stat.(lbmat)(stat.(lbmat) == hcl) = clst_ind;           

            % update num clusters
            holmes_stat.(['num_', fld{1}(1:3)]) = clst_ind;
        end
    end
end