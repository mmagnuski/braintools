function [vals, pos] = find_ticklabels(vec, numlabels)

% calculate positions of ticks on colorbar
% given the mapping values

if ~exist('numlabels', 'var') || isempty(numlabels)
    numlabels = 9;
elseif mod(numlabels, 2) == 0
    numlabels = numlabels + 1;
end

edges = vec([1,end]);
rng = diff(edges);

base = [0.0001, 0.00025, 0.0005];
found_val = false;
loop_ind = 1;
dist = zeros(1000, 1);

% instead of a dumb loop it could estimate the range
% of values straight away
while ~found_val && loop_ind < 1001
    ind = mod(loop_ind, 3);
    multip = 10^(floor((loop_ind-1) / 3));
    if ind == 0; ind = 3; end
    val = base(ind) * multip;
    found_val = (round(rng / val) + 1) == numlabels;
    dist(loop_ind) = numlabels - (round(rng / val) + 1);
    
    if loop_ind == 1
        min_dist = abs(dist(1));
        min_val = val;
    elseif abs(dist(loop_ind)) < min_dist
        min_dist = abs(dist(loop_ind));
        min_val = val;
    else
        val = min_val;
        break
    end
    loop_ind = loop_ind + 1;
end

% match pixel mode:
% rnd_val = round(vec / val);
% howfar = vec - rnd_val;
% diffar = diff(howfar);
% m = mean(diffar);
% break_inds = find(diffar < m);

% for brak_inds:
% [~,i] = min(abs(test(prev_b_ind+1:b_ind)))

% continuous mode:
% currently assume 0 is in the middle:
range_mult = (1:numlabels) - ceil(numlabels/2);
vals = range_mult * val;

% remove out of range vals:
out1 = vals < edges(1);
vals(out1) = [];
range_mult(out1) = [];
out2 = vals > edges(2);
vals(out2) = [];
range_mult(out2) = [];

unit = 1/(rng / val);
pos = (range_mult * unit + 0.5) * length(vec);