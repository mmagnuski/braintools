function cluster_val = compute_cluster_val(labelmat, valmat, fun)

clst_ind = 1:max(labelmat(:));
cluster_val = arrayfun(@(x) fun(...
    valmat(find(labelmat == x))), clst_ind);
