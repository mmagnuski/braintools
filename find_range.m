function ind = rangefind(vec, range)

% rangefind(vec, range)
% looks in vector vec for points closest
% to desired values specified in range
% vec should be a vector of increasing values
%
% Example:
% ind = rangefind([1, 3, 4, 8, 20, 22], [2.5, 9])
% ind =
%      2     4
%
% by Miko the Wombat King

ind = arrayfun(@(x) find( abs(vec - x) == ...
    min(abs(vec - x)), 1), range);