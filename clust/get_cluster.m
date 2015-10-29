function clst = get_cluster(stat, pval, pol)

% GET_CLUSTER get cluster info from stat structure:
% cluster edges, electrodes participating in the cluster etc.
% FIXHELPINFO

% TODOs:
% [ ] turn into an object with lazy+persistent param evaluation

if ~exist('pol', 'var') || isempty(pol)
    pol = 'both';
end

if ~exist('pval', 'var') || isempty(pval)
    pval = 0.05;
end


% clusterslabelmat (pos) or (neg):
if strcmp(pol, 'both')
    fld = cellfun(@(x) [x, 'clusters'], {'pos', 'neg'}, ...
        'Uni', false);
    fldmat = cellfun(@(x) [x, 'labelmat'], fld, ...
        'Uni', false);
else
    fld = {[pol, 'clusters']};
    fldmat = {[fld{1}, 'labelmat']};
end

clst = struct();
ci = 1;

for f = 1:length(fld)

    % check whether field exists:
    if ~femp(stat, fld{f})
        continue
    end

    % check probability
    try
        prob   = [stat.(fld{f}).prob];
    catch %#ok<*CTCH>
        prob = [stat.(fld{f}).p];
    end

    signif = find(prob < pval);

    if ~isempty(signif)
        for s = 1:length(signif)
            % construct useful cluster fields
            clst(ci).pol      = fld{f}(1:3);
            clst(ci).prob     = prob(signif(s));
            clst(ci).boolmat  = stat.(fldmat{f}) == signif(s);
            clst(ci).samples  = find(sum(clst(ci).boolmat > 0, 1));
            clst(ci).nsamp    = length(clst(ci).samples);
            clst(ci).edges    = clst(ci).samples([1, end]);
            clst(ci).elecs    = find(sum(clst(ci).boolmat > 0, 2));

            % chan labels
            try %#ok<*TRYNC>
                clst(ci).label    = stat.label(clst(s).elecs);
            end
            % time labels
            try
                clst(ci).time     = stat.time(clst(ci).samples);
                clst(ci).timedges = clst(ci).time([1, end]);
            end
            ci = ci + 1;
        end
    end
end