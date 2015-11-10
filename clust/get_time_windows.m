function twin = get_time_windows(stat, pval, nwin)

% GET_TIME_WINDOWS allows to get time windows
% when any significant cluster activity is pre-
% sent
% 
% returns:
% structure with fields:
%     samples  - timesamples of each window limits
%                in a window X limits matrix
%     times    - times of each window limits
%                in a window X limits matrix

% TODOs:
% [ ] integrate with get_cluster ?
% [ ] currently assumes that all signif
%     activity is overlapping in time
%     - what should be done if this assumption
%       is not met?

if ~exist('pval', 'var')
    pval = 0.05;
end

% CHANGE - nwin could be estimated to optimally 
%          present data or to have each window
%          not longer than some time amount
if ~exist('nwin', 'var')
    nwin = 4;
end

% get clusters
pc = get_cluster(stat, pval, 'pos');
nc = get_cluster(stat, pval, 'neg');

% get times
tim = false(size(stat.time));
if ~isempty(pc) && ~isempty(fields(pc))
    for c = 1:length(pc)
        tim(pc(c).samples) = true;
    end
end
if ~isempty(nc) && ~isempty(fields(nc))
    for c = 1:length(nc)
        tim(nc(c).samples) = true;
    end
end

% find time limits
wins = group(tim);
wins(wins(:,1)==0,:) = [];
wins = wins(:,2:3);

% calculate window samples:
lens = diff(wins, [], 2) + 1;
total_time  = sum(lens);
window_time = round(total_time / nwin);

% extend/shorten tlimits in some cases:
% tol = 10;
% new_total_time = window_time * nwin;
% diff_time = new_total_time - total_time;
% if abs(diff_time) <= tol
%     p1 = round(diff_time / 2);
%     p2 = diff_time - p1;
%     tlim = tlim - [p1, p2];
% end

% create window limits
do_not_win = round(0.25 * window_time);
win_start_samples = [];
for r = 1:size(lens, 1)
    current_wins = wins(r, 1):window_time:wins(r,2);
    last_len = wins(r,2) - current_wins(end) + 1;
    if last_len <= do_not_win
        current_wins(end) = [];
    end
    win_start_samples = [win_start_samples, current_wins]; %#ok<AGROW>
end
twin.samples = [win_start_samples', win_start_samples' + window_time - 1];
twin.times   = stat.time(twin.samples);